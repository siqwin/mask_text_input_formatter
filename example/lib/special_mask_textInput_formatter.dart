import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SpecialMaskTextInputFormatter extends MaskTextInputFormatter {
  SpecialMaskTextInputFormatter({this.mask, this.filter, this.initialText})
      : super(
          mask: mask,
          filter: filter,
          initialText: initialText,
        );

  final String? mask;
  final Map<String, RegExp>? filter;
  final String? initialText;

  List<String> _maskChars = [];
  Map<String, RegExp>? _maskFilter;

  int _maskLength = 0;
  final _TextMatcher _resultTextArray = _TextMatcher();
  String _resultTextMasked = "";

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final mask = getMask();

    if (mask == null || mask.isEmpty == true) {
      _resultTextMasked = newValue.text;
      _resultTextArray.set(newValue.text);
      return newValue;
    }

    if (oldValue.text.isEmpty) {
      _resultTextArray.clear();
    }

    final beforeText = oldValue.text;
    final afterText = newValue.text;

    final beforeSelection = oldValue.selection;
    final afterSelection = newValue.selection;

    var beforeSelectionStart = afterSelection.isValid
        ? beforeSelection.isValid
            ? beforeSelection.start
            : 0
        : 0;

    for (var i = 0; i < beforeSelectionStart && i < beforeText.length && i < afterText.length; i++) {
      if (beforeText[i] != afterText[i]) {
        beforeSelectionStart = i;
        break;
      }
    }

    final beforeSelectionLength = afterSelection.isValid
        ? beforeSelection.isValid
            ? beforeSelection.end - beforeSelectionStart
            : 0
        : oldValue.text.length;

    final lengthDifference = afterText.length - (beforeText.length - beforeSelectionLength);
    final lengthRemoved = lengthDifference < 0 ? lengthDifference.abs() : 0;
    final lengthAdded = lengthDifference > 0 ? lengthDifference : 0;

    final afterChangeStart = max(0, beforeSelectionStart - lengthRemoved);
    final afterChangeEnd = max(0, afterChangeStart + lengthAdded);

    final beforeReplaceStart = max(0, beforeSelectionStart - lengthRemoved);
    final beforeReplaceLength = beforeSelectionLength + lengthRemoved;

    final beforeResultTextLength = _resultTextArray.length;

    var currentResultTextLength = _resultTextArray.length;
    var currentResultSelectionStart = 0;
    var currentResultSelectionLength = 0;

    for (var i = 0; i < min(beforeReplaceStart + beforeReplaceLength, mask.length); i++) {
      if (_maskChars.contains(mask[i]) && currentResultTextLength > 0) {
        currentResultTextLength -= 1;
        if (i < beforeReplaceStart) {
          currentResultSelectionStart += 1;
        }
        if (i >= beforeReplaceStart) {
          currentResultSelectionLength += 1;
        }
      }
    }

    final replacementText = afterText.substring(afterChangeStart, afterChangeEnd);
    var targetCursorPosition = currentResultSelectionStart;
    if (replacementText.isEmpty) {
      _resultTextArray.removeRange(
          currentResultSelectionStart, currentResultSelectionStart + currentResultSelectionLength);
    } else {
      if (currentResultSelectionLength > 0) {
        _resultTextArray.removeRange(
            currentResultSelectionStart, currentResultSelectionStart + currentResultSelectionLength);
        currentResultSelectionLength = 0;
      }
      _resultTextArray.insert(currentResultSelectionStart, replacementText);
      targetCursorPosition += replacementText.length;
    }

    if (beforeResultTextLength == 0 && _resultTextArray.length > 1) {
      for (var i = 0; i < mask.length; i++) {
        if (_maskChars.contains(mask[i])) {
          final resultPrefix = _resultTextArray._symbolArray.take(i).toList();
          for (var j = 0; j < resultPrefix.length; j++) {
            if (_resultTextArray.length <= j ||
                (mask[j] != resultPrefix[j] || (mask[j] == resultPrefix[j] && j == resultPrefix.length - 1))) {
              // _resultTextArray.removeRange(0, j);
              _resultTextArray.removeRange(0, resultPrefix.length);
              break;
            }
          }
          break;
        }
      }
    }

    var curTextPos = 0;
    var maskPos = 0;
    _resultTextMasked = "";
    var cursorPos = -1;
    var nonMaskedCount = 0;

    while (maskPos < mask.length) {
      final curMaskChar = mask[maskPos];
      final isMaskChar = _maskChars.contains(curMaskChar);

      var curTextInRange = curTextPos < _resultTextArray.length;

      String? curTextChar;
      if (isMaskChar && curTextInRange) {
        while (curTextChar == null && curTextInRange) {
          // final potentialTextChar = _resultTextArray[curTextPos];
          final index = _resultTextArray.length == mask.length ? maskPos : curTextPos; // added
          final potentialTextChar = _resultTextArray[index]; //  added
          if (_maskFilter?[curMaskChar]?.hasMatch(potentialTextChar) ?? false) {
            curTextChar = potentialTextChar;
          } else {
            _resultTextArray.removeAt(curTextPos);
            curTextInRange = curTextPos < _resultTextArray.length;
            if (curTextPos <= targetCursorPosition) {
              targetCursorPosition -= 1;
            }
          }
        }
      } else if (!isMaskChar && !curTextInRange && type == MaskAutoCompletionType.eager) {
        curTextInRange = true;
      }

      if (isMaskChar && curTextInRange && curTextChar != null) {
        _resultTextMasked += curTextChar;
        if (curTextPos == targetCursorPosition && cursorPos == -1) {
          cursorPos = maskPos - nonMaskedCount;
        }
        nonMaskedCount = 0;
        curTextPos += 1;
      } else {
        if (curTextPos == targetCursorPosition && cursorPos == -1 && !curTextInRange) {
          cursorPos = maskPos;
        }

        if (!curTextInRange) {
          break;
        } else {
          _resultTextMasked += mask[maskPos];
        }

        if (type == MaskAutoCompletionType.lazy ||
            lengthRemoved > 0 ||
            currentResultSelectionLength > 0 ||
            beforeReplaceLength > 0) {
          nonMaskedCount++;
        }
      }

      maskPos++;
    }

    if (nonMaskedCount > 0) {
      _resultTextMasked = _resultTextMasked.substring(0, _resultTextMasked.length - nonMaskedCount);
      cursorPos -= nonMaskedCount;
    }

    if (_resultTextArray.length > _maskLength) {
      _resultTextArray.removeRange(_maskLength, _resultTextArray.length);
    }

    final finalCursorPosition = cursorPos < 0 ? _resultTextMasked.length : cursorPos;

    return TextEditingValue(
      text: _resultTextMasked,
      selection: TextSelection(
        baseOffset: finalCursorPosition,
        extentOffset: finalCursorPosition,
        affinity: newValue.selection.affinity,
        isDirectional: newValue.selection.isDirectional,
      ),
    );
  }
}

class _TextMatcher {
  final List<String> _symbolArray = <String>[];

  int get length => _symbolArray.fold(0, (prev, match) => prev + match.length);

  void removeRange(int start, int end) => _symbolArray.removeRange(start, end);

  void insert(int start, String substring) {
    for (var i = 0; i < substring.length; i++) {
      _symbolArray.insert(start + i, substring[i]);
    }
  }

  bool get isEmpty => _symbolArray.isEmpty;

  void removeAt(int index) => _symbolArray.removeAt(index);

  String operator [](int index) => _symbolArray[index];

  void clear() => _symbolArray.clear();

  @override
  String toString() => _symbolArray.join();

  void set(String text) {
    _symbolArray.clear();
    for (var i = 0; i < text.length; i++) {
      _symbolArray.add(text[i]);
    }
  }
}

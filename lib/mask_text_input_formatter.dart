import 'dart:math';

import 'package:flutter/services.dart';

enum MaskAutoCompletionType {
  lazy,
  eager,
}

class MaskTextInputFormatter implements TextInputFormatter {

  MaskAutoCompletionType _type;
  MaskAutoCompletionType get type => _type;

  String? _mask;
  List<String> _maskChars = [];
  Map<String, RegExp>? _maskFilter;

  int _maskLength = 0;
  final _TextMatcher _resultTextArray = _TextMatcher();
  String _resultTextMasked = "";

  /// Create the [mask] formatter for TextField
  ///
  /// The keys of the [filter] assign which character in the mask should be replaced and the values validate the entered character
  /// By default `#` match to the number and `A` to the letter
  ///
  /// Set [type] for autocompletion behavior:
  ///  - [MaskAutoCompletionType.lazy] (default): autocomplete unfiltered characters once the following filtered character is input.
  ///  For example, with the mask "#/#" and the sequence of characters "1" then "2", the formatter will output "1", then "1/2"
  ///  - [MaskAutoCompletionType.eager]: autocomplete unfiltered characters when the previous filtered character is input.
  ///  For example, with the mask "#/#" and the sequence of characters "1" then "2", the formatter will output "1/", then "1/2"
  MaskTextInputFormatter({
    String? mask,
    Map<String, RegExp>? filter,
    String? initialText,
    MaskAutoCompletionType type = MaskAutoCompletionType.lazy,
  }): _type = type {
    updateMask(
      mask: mask,
      filter: filter ?? {"#": RegExp('[0-9]'), "A": RegExp('[^0-9]')},
      newValue: initialText == null ? null : TextEditingValue(text: initialText, selection: TextSelection.collapsed(offset: initialText.length))
    );
  }

  /// Create the eager [mask] formatter for TextField
  MaskTextInputFormatter.eager({
    String? mask,
    Map<String, RegExp>? filter,
    String? initialText,
  }): this(
    mask: mask,
    filter: filter,
    initialText: initialText,
    type: MaskAutoCompletionType.eager
  );

  /// Change the mask
  TextEditingValue updateMask({ String? mask, Map<String, RegExp>? filter, MaskAutoCompletionType? type, TextEditingValue? newValue}) {
    _mask = mask;
    if (filter != null) {
      _updateFilter(filter);
    }
    if (type != null) {
      _type = type;
    }
    _calcMaskLength();
    TextEditingValue? targetValue = newValue;
    if (targetValue == null) {
      final unmaskedText = getUnmaskedText();
      targetValue = TextEditingValue(text: unmaskedText, selection: TextSelection.collapsed(offset: unmaskedText.length));
    }
    clear();
    return formatEditUpdate(TextEditingValue.empty, targetValue);
  }

  /// Get current mask
  String? getMask() {
    return _mask;
  }

  /// Get masked text, e.g. "+0 (123) 456-78-90"
  String getMaskedText() {
    return _resultTextMasked;
  }

  /// Get unmasked text, e.g. "01234567890"
  String getUnmaskedText() {
    return _resultTextArray.toString();
  }

  /// Check if target mask is filled
  bool isFill() {
    return _resultTextArray.length == _maskLength;
  }

  /// Clear masked text of the formatter
  /// Note: you need to call this method if you clear the text of the TextField because it doesn't call the formatter when it has empty text
  void clear() {
    _resultTextMasked = "";
    _resultTextArray.clear();
  }

  /// Mask some text
  String maskText(String text) {
    return MaskTextInputFormatter(mask: _mask, filter: _maskFilter, initialText: text).getMaskedText();
  }

  /// Unmask some text
  String unmaskText(String text) {
    return MaskTextInputFormatter(mask: _mask, filter: _maskFilter, initialText: text).getUnmaskedText();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final mask = _mask;

    String newValueReplacement = _replacePersianNumber(newValue.text);

    if (mask == null || mask.isEmpty == true) {
      _resultTextMasked = newValueReplacement;
      _resultTextArray.set(newValueReplacement);
      return newValue;
    }

    if (oldValue.text.isEmpty) {
      _resultTextArray.clear();
    }

    final beforeText = oldValue.text;
    final afterText = newValueReplacement;

    final beforeSelection = oldValue.selection;
    final afterSelection = newValue.selection;

    var beforeSelectionStart = afterSelection.isValid ? beforeSelection.isValid ? beforeSelection.start : 0 : 0;

    for (var i = 0; i < beforeSelectionStart && i < beforeText.length && i < afterText.length; i++) {
      if (beforeText[i] != afterText[i]) {
        beforeSelectionStart = i;
        break;
      }
    }

    final beforeSelectionLength = afterSelection.isValid ? beforeSelection.isValid ? beforeSelection.end - beforeSelectionStart : 0 : oldValue.text.length;

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
      _resultTextArray.removeRange(currentResultSelectionStart, currentResultSelectionStart + currentResultSelectionLength);
    } else {
      if (currentResultSelectionLength > 0) {
        _resultTextArray.removeRange(currentResultSelectionStart, currentResultSelectionStart + currentResultSelectionLength);
        currentResultSelectionLength = 0;
      }
      _resultTextArray.insert(currentResultSelectionStart, replacementText);
      targetCursorPosition += replacementText.length;
    }

    if (beforeResultTextLength == 0 && _resultTextArray.length  > 1) {
      var prefixLength = 0;
      for (var i = 0; i < mask.length; i++) {
        if (_maskChars.contains(mask[i])) {
          prefixLength = i;
          break;
        }
      }
      if (prefixLength > 0) {
        final resultPrefix = _resultTextArray._symbolArray.take(prefixLength).toList();
        final effectivePrefixLength = min(_resultTextArray.length, resultPrefix.length);
        for (var j = 0; j < effectivePrefixLength; j++) {
          if (mask[j] != resultPrefix[j]) {
            _resultTextArray.removeRange(0, j);
            break;
          }
          if (j == effectivePrefixLength - 1) {
            _resultTextArray.removeRange(0, effectivePrefixLength);
            break;
          }
        }
      }
    }

    var curTextPos = 0;
    var maskPos = 0;
    _resultTextMasked = "";
    var cursorPos = -1;
    var nonMaskedCount = 0;
    var maskInside = 0;

    while (maskPos < mask.length) {
      final curMaskChar = mask[maskPos];
      final isMaskChar = _maskChars.contains(curMaskChar);

      var curTextInRange = curTextPos < _resultTextArray.length;

      String? curTextChar;
      if (isMaskChar && curTextInRange) {
        if (maskInside > 0) {
          _resultTextArray.removeRange(curTextPos - maskInside, curTextPos);
          curTextPos -= maskInside;
        }
        maskInside = 0;
        while (curTextChar == null && curTextInRange) {
          final potentialTextChar = _resultTextArray[curTextPos];
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
        if (!curTextInRange) {
          if (maskInside > 0) {
            curTextPos -= maskInside;
            maskInside = 0;
            nonMaskedCount = 0;
            continue;
          } else {
            break;
          }
        } else {
          _resultTextMasked += mask[maskPos];
          if (!isMaskChar && curTextPos < _resultTextArray.length && curMaskChar == _resultTextArray[curTextPos]) {
            if (type == MaskAutoCompletionType.lazy && lengthAdded <= 1) {
            } else {
              maskInside++;
              curTextPos++;
            }
          } else if (maskInside > 0) {
            curTextPos -= maskInside;
            maskInside = 0;
          }
        }

        if (curTextPos == targetCursorPosition && cursorPos == -1 && !curTextInRange) {
          cursorPos = maskPos;
        }

        if (type == MaskAutoCompletionType.lazy || lengthRemoved > 0 || currentResultSelectionLength > 0 || beforeReplaceLength > 0) {
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
        isDirectional: newValue.selection.isDirectional
      )
    );
  }

  String _replacePersianNumber(String text) => text
      .replaceAll('١', '1')
      .replaceAll('٢', '2')
      .replaceAll('٣', '3')
      .replaceAll('٤', '4')
      .replaceAll('٥', '5')
      .replaceAll('٦', '6')
      .replaceAll('٧', '7')
      .replaceAll('٨', '8')
      .replaceAll('٩', '9')
      .replaceAll('٠', '0');

  void _calcMaskLength() {
    _maskLength = 0;
    final mask = _mask;
    if (mask != null) {
      for (var i = 0; i < mask.length; i++) {
        if (_maskChars.contains(mask[i])) {
          _maskLength++;
        }
      }
    }
  }

  void _updateFilter(Map<String, RegExp> filter) {
    _maskFilter = filter;
    _maskChars = _maskFilter?.keys.toList(growable: false) ?? [];
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

  void removeAt(int index) => _symbolArray.removeAt(index);

  String operator[](int index) => _symbolArray[index];

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

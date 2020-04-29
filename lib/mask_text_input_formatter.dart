import 'package:flutter/services.dart';

class MaskTextInputFormatter extends TextInputFormatter {
  String _mask;
  List<String> _maskChars;
  Map<String, RegExp> _maskFilter;

  int _maskLength;
  final _resultTextArray = <String>[];
  String _resultTextMasked = "";

  MaskTextInputFormatter({
    String mask = "+# (###) ###-##-##",
    Map<String, RegExp> filter,
  })  : assert(mask != null),
        assert(mask.isNotEmpty) {
    updateMask(
      mask,
      filter: filter ??
          {
            "#": RegExp(r'[0-9]'),
            "A": RegExp(r'[^0-9]'),
          },
    );
  }

  TextEditingValue updateMask(
    String mask, {
    Map<String, RegExp> filter,
  }) {
    _mask = mask;
    if (filter != null) {
      _updateFilter(filter);
    }
    _calcMaskLength();
    final String unmaskedText = getUnmaskedText();
    _resultTextArray.clear();
    _resultTextMasked = "";
    return _formatUpdate(
      TextEditingValue(),
      TextEditingValue(
        text: unmaskedText,
        selection: TextSelection(
          baseOffset: unmaskedText.length,
          extentOffset: unmaskedText.length,
        ),
      ),
    );
  }

  String getMaskedText() {
    return _resultTextMasked;
  }

  String getUnmaskedText() {
    return _resultTextArray.join();
  }

  bool isFill() {
    return _resultTextArray.length == _maskLength;
  }

  TextEditingValue lastResValue;
  TextEditingValue lastOldValue;
  TextEditingValue lastNewValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (lastResValue == oldValue && newValue == lastNewValue) {
      return lastResValue;
    }
    lastOldValue = oldValue;
    lastNewValue = newValue;
    lastResValue = _formatUpdate(oldValue, newValue);
    return lastResValue;
  }

  TextEditingValue _formatUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final selectionBefore = oldValue.selection;

    final String textBefore = oldValue.text;
    final String textAfter = newValue.text;

    final startBefore = selectionBefore.start == -1 ? 0 : selectionBefore.start;
    final countBefore = selectionBefore.start == -1 || selectionBefore.end == -1
        ? 0
        : selectionBefore.end - selectionBefore.start;

    final after = textAfter.length - (textBefore.length - countBefore);
    final removed = after < 0 ? after.abs() : 0;

    final startAfter = startBefore + (after < 0 ? after : 0);
    final endAfter = startAfter + (after > 0 ? after : 0);

    final replaceStart = startBefore - removed;
    final replaceLength = countBefore + removed;

    final beforeResultTextLength = _resultTextArray.length;

    int currentTotalText = _resultTextArray.length;
    int selectionStart = 0;
    int selectionLength = 0;
    for (var i = 0; i < replaceStart + replaceLength; i++) {
      if (_maskChars.contains(_mask[i]) && currentTotalText > 0) {
        currentTotalText -= 1;
        if (i < replaceStart) {
          selectionStart += 1;
        }
        if (i >= replaceStart) {
          selectionLength += 1;
        }
      }
    }

    final String replacementText = textAfter.substring(startAfter, endAfter);
    int targetCursorPosition = selectionStart;
    if (replacementText.isEmpty) {
      _resultTextArray.removeRange(
        selectionStart,
        selectionStart + selectionLength,
      );
    } else {
      if (selectionLength > 0) {
        _resultTextArray.removeRange(
          selectionStart,
          selectionStart + selectionLength,
        );
      }
      _insertToResultText(selectionStart, replacementText);
      targetCursorPosition += replacementText.length;
    }

    if (beforeResultTextLength == 0 && _resultTextArray.length > 1) {
      for (var i = 0; i < _mask.length; i++) {
        if (_maskChars.contains(_mask[i]) || _resultTextArray.length == 0) {
          break;
        } else if (_mask[i] == _resultTextArray[0]) {
          _resultTextArray.removeAt(0);
        }
      }
    }

    int curTextPos = 0;
    int maskPos = 0;
    _resultTextMasked = "";
    int cursorPos = -1;
    int nonMaskedCount = 0;

    while (maskPos < _mask.length) {
      final String curMaskChar = _mask[maskPos];
      final bool isMaskChar = _maskChars.contains(curMaskChar);

      bool curTextInRange = curTextPos < _resultTextArray.length;

      String curTextChar;
      if (isMaskChar && curTextInRange) {
        while (curTextChar == null && curTextInRange) {
          final String potentialTextChar = _resultTextArray[curTextPos];
          if (_maskFilter[curMaskChar].hasMatch(potentialTextChar)) {
            curTextChar = potentialTextChar;
          } else {
            _resultTextArray.removeAt(curTextPos);
            curTextInRange = curTextPos < _resultTextArray.length;
            if (curTextPos <= targetCursorPosition) {
              targetCursorPosition -= 1;
            }
          }
        }
      }

      if (isMaskChar && curTextInRange) {
        _resultTextMasked += curTextChar;
        if (curTextPos == targetCursorPosition && cursorPos == -1) {
          cursorPos = maskPos - nonMaskedCount;
        }
        nonMaskedCount = 0;
        curTextPos += 1;
      } else {
        if (curTextPos == targetCursorPosition &&
            cursorPos == -1 &&
            !curTextInRange) {
          cursorPos = maskPos;
        }

        if (!curTextInRange) {
          break;
        } else {
          _resultTextMasked += _mask[maskPos];
        }

        nonMaskedCount++;
      }

      maskPos += 1;
    }

    if (nonMaskedCount > 0) {
      _resultTextMasked = _resultTextMasked.substring(
        0,
        _resultTextMasked.length - nonMaskedCount,
      );
      cursorPos -= nonMaskedCount;
    }

    if (_resultTextArray.length > _maskLength) {
      _resultTextArray.removeRange(_maskLength, _resultTextArray.length);
    }

    int finalCursorPosition =
        cursorPos == -1 ? _resultTextMasked.length : cursorPos;

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

  void _insertToResultText(int start, String substring) {
    for (var i = 0; i < substring.length; i++) {
      _resultTextArray.insert(start + i, substring[i]);
    }
  }

  void _calcMaskLength() {
    _maskLength = 0;
    for (int i = 0; i < _mask.length; i++) {
      if (_maskChars.contains(_mask[i])) {
        _maskLength++;
      }
    }
  }

  void _updateFilter(Map<String, RegExp> filter) {
    _maskFilter = filter;
    _maskChars = _maskFilter.keys.toList(growable: false);
  }

  String get mask => _mask;
}

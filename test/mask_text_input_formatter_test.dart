import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {

  test('Type', () {
    String phoneMask = "+# (###) ###-##-##";
    String phone = "01234567890";
    String expectResult = "+0 (123) 456-78-90";

    MaskTextInputFormatter maskTextInputFormatter = MaskTextInputFormatter(mask: phoneMask);
    TextEditingValue currentTextEditingValue = TextEditingValue();
    for (var i = 0; i < phone.length; i++) {
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: currentTextEditingValue.text + phone[i]));
      expect(expectResult.startsWith(currentTextEditingValue.text), true);
      expect(maskTextInputFormatter.isFill(), i == phone.length - 1 ? true : false);
      expect(maskTextInputFormatter.getUnmaskedText(), phone.substring(0, i + 1));
      expect(maskTextInputFormatter.getMaskedText(), currentTextEditingValue.text);
    }
  });

  test('Insert and Remove', () {
    final maskTextInputFormatter = MaskTextInputFormatter();
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "01234567"));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (123) 456-7", selection: TextSelection(baseOffset: 14, extentOffset: 14)));
    expect(maskTextInputFormatter.isFill(), false);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-7");
    expect(maskTextInputFormatter.getUnmaskedText(), "01234567");

    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: currentTextEditingValue.text + "890"));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection(baseOffset: 18, extentOffset: 18)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
    expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");

    currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: TextSelection(baseOffset: 5, extentOffset: 7));
    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: "+0 (1) 456-78-90"));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (145) 678-90", selection: TextSelection(baseOffset: 5, extentOffset: 5)));
    expect(maskTextInputFormatter.isFill(), false);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (145) 678-90");
    expect(maskTextInputFormatter.getUnmaskedText(), "014567890");

    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: "+0 (132) 456-78-90", selection: TextSelection(baseOffset: 9, extentOffset: 9)));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (132) 456-78-90", selection: TextSelection(baseOffset: 9, extentOffset: 9)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (132) 456-78-90");
    expect(maskTextInputFormatter.getUnmaskedText(), "01324567890");
  });

  test('Update mask', () {
    String firstMask = "####-####";
    String secondMask = "##/##-##/##";

    MaskTextInputFormatter maskTextInputFormatter = MaskTextInputFormatter(mask: firstMask);
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "12345678"));
    expect(currentTextEditingValue, TextEditingValue(text: "1234-5678", selection: TextSelection(baseOffset: 9, extentOffset: 9)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "1234-5678");
    expect(maskTextInputFormatter.getUnmaskedText(), "12345678");

    currentTextEditingValue = maskTextInputFormatter.updateMask(secondMask);
    expect(currentTextEditingValue, TextEditingValue(text: "12/34-56/78", selection: TextSelection(baseOffset: 11, extentOffset: 11)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "12/34-56/78");
    expect(maskTextInputFormatter.getUnmaskedText(), "12345678");
  });
}

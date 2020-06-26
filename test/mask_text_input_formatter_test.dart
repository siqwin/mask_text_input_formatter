import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {

  test('Assert', () {
    expect(() => MaskTextInputFormatter(mask: null), throwsAssertionError);
    expect(() => MaskTextInputFormatter(mask: ""), throwsAssertionError);
  });

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

  test('Insert start', () {
    final maskTextInputFormatter = MaskTextInputFormatter();
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "01234567", selection: TextSelection.collapsed(offset: 8)));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (123) 456-7", selection: TextSelection.collapsed(offset: 14)));
    expect(maskTextInputFormatter.isFill(), false);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-7");
    expect(maskTextInputFormatter.getUnmaskedText(), "01234567");
  });

  test('Insert end', () {
    final maskTextInputFormatter = MaskTextInputFormatter();
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "01234567", selection: TextSelection.collapsed(offset: 8)));
    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: "+0 (123) 456-7890", selection: TextSelection.collapsed(offset: 18)));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
    expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
  });

  test('Insert overflow', () {
    final maskTextInputFormatter = MaskTextInputFormatter();
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "01234567890123456", selection: TextSelection.collapsed(offset: 18)));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
    expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
  });

  test('Insert with incorrect symbols', () {
    final maskTextInputFormatter = MaskTextInputFormatter();
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
    expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
  });

  test('Remove part', () {
    final maskTextInputFormatter = MaskTextInputFormatter();
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
    currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: TextSelection(baseOffset: 5, extentOffset: 7));
    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: "+0 (1) 456-78-90", selection: TextSelection.collapsed(offset: 5)));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (145) 678-90", selection: TextSelection.collapsed(offset: 5)));
    expect(maskTextInputFormatter.isFill(), false);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (145) 678-90");
    expect(maskTextInputFormatter.getUnmaskedText(), "014567890");
  });


  test('Remove all', () {
    final maskTextInputFormatter = MaskTextInputFormatter();
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue.empty);
    expect(maskTextInputFormatter.isFill(), false);
    expect(maskTextInputFormatter.getMaskedText(), "");
    expect(maskTextInputFormatter.getUnmaskedText(), "");
  });

  test('Remove part 2', () {
    final maskTextInputFormatter = MaskTextInputFormatter(mask: "(###) ###-##-##");
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "2555555", selection: TextSelection.collapsed(offset: 11)));
    currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: TextSelection.collapsed(offset: 11));

    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: "(255) 555-", selection: TextSelection.collapsed(offset: 10)));
    expect(currentTextEditingValue, TextEditingValue(text: "(255) 555", selection: TextSelection.collapsed(offset: 9)));

    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: "(255) 55", selection: TextSelection.collapsed(offset: 8)));
    expect(currentTextEditingValue, TextEditingValue(text: "(255) 55", selection: TextSelection.collapsed(offset: 8)));
  });

  test('Remove with mask part', () {
    final maskTextInputFormatter = MaskTextInputFormatter();
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
    currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: TextSelection(baseOffset: 5, extentOffset: 10));
    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: "+0 (156-78-90", selection: TextSelection.collapsed(offset: 5)));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (156) 789-0", selection: TextSelection.collapsed(offset: 5)));
    expect(maskTextInputFormatter.isFill(), false);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (156) 789-0");
    expect(maskTextInputFormatter.getUnmaskedText(), "01567890");
  });

  test('Replace', () {
    final maskTextInputFormatter = MaskTextInputFormatter();
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
    currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: TextSelection(baseOffset: 4, extentOffset: 7));
    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: "+0 (132) 456-78-90", selection: TextSelection.collapsed(offset: 7)));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (132) 456-78-90", selection: TextSelection.collapsed(offset: 7)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (132) 456-78-90");
    expect(maskTextInputFormatter.getUnmaskedText(), "01324567890");
  });

  test('Replace with mask part', () {
    final maskTextInputFormatter = MaskTextInputFormatter();
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "04321567890", selection: TextSelection.collapsed(offset: 11)));
    currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: TextSelection(baseOffset: 4, extentOffset: 10));
    currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 10)));
    expect(currentTextEditingValue, TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 10)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
    expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
  });

  test('Update mask', () {
    String firstMask = "####-####";
    String secondMask = "##/##-##/##";

    MaskTextInputFormatter maskTextInputFormatter = MaskTextInputFormatter(mask: firstMask);
    TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "12345678"));
    expect(currentTextEditingValue, TextEditingValue(text: "1234-5678", selection: TextSelection.collapsed(offset: 9)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "1234-5678");
    expect(maskTextInputFormatter.getUnmaskedText(), "12345678");

    currentTextEditingValue = maskTextInputFormatter.updateMask(secondMask);
    expect(currentTextEditingValue, TextEditingValue(text: "12/34-56/78", selection: TextSelection.collapsed(offset: 11)));
    expect(maskTextInputFormatter.isFill(), true);
    expect(maskTextInputFormatter.getMaskedText(), "12/34-56/78");
    expect(maskTextInputFormatter.getUnmaskedText(), "12345678");
  });

  test('Paste full phone number', () {
    final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##");
    maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "+12345678901", selection: TextSelection.collapsed(offset: 12)));
    expect(maskTextInputFormatter.getMaskedText(), "+1 (234) 567-89-01");
  });

  test('Paste full phone number with spec symbols', () {
    final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##");
    maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "+1 (234) 567-89-01", selection: TextSelection.collapsed(offset: 12)));
    expect(maskTextInputFormatter.getMaskedText(), "+1 (234) 567-89-01");
  });
  
  test('Clear text', () {
    final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##");
    maskTextInputFormatter.formatEditUpdate(TextEditingValue(), TextEditingValue(text: "+1 (234) 567-89-01", selection: TextSelection.collapsed(offset: 12)));
    maskTextInputFormatter.clear();
    expect(maskTextInputFormatter.isFill(), false);
    expect(maskTextInputFormatter.getMaskedText(), "");
    expect(maskTextInputFormatter.getUnmaskedText(), "");
  });
}

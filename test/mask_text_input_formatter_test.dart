import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {

  group("Mask Text Input Formatter Tests", () {

    test('Type', () {
      const String phone = "01234567890";
      const String expectResult = "+0 (123) 456-78-90";

      final MaskTextInputFormatter maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      TextEditingValue currentTextEditingValue = const TextEditingValue();
      for (var i = 0; i < phone.length; i++) {
        currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: currentTextEditingValue.text + phone[i]));
        expect(expectResult.startsWith(currentTextEditingValue.text), true);
        expect(maskTextInputFormatter.isFill(), i == phone.length - 1);
        expect(maskTextInputFormatter.getUnmaskedText(), phone.substring(0, i + 1));
        expect(maskTextInputFormatter.getMaskedText(), currentTextEditingValue.text);
      }
    });

    test('Insert - Start', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      final TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "01234567", selection: TextSelection.collapsed(offset: 8)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-7", selection: TextSelection.collapsed(offset: 14)));
      expect(maskTextInputFormatter.isFill(), false);
      expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-7");
      expect(maskTextInputFormatter.getUnmaskedText(), "01234567");
    });

    test('Insert - End', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "01234567", selection: TextSelection.collapsed(offset: 8)));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-7890", selection: TextSelection.collapsed(offset: 18)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
      expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
    });

    test('Insert - Overflow', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      final TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "01234567890123456", selection: TextSelection.collapsed(offset: 18)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
      expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
    });

    test('Insert - Overflow - 2', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "###");
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "123", selection: TextSelection.collapsed(offset: 3)));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "1234", selection: TextSelection.collapsed(offset: 4)));
      expect(currentTextEditingValue, const TextEditingValue(text: "123", selection: TextSelection.collapsed(offset: 3)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getMaskedText(), "123");
      expect(maskTextInputFormatter.getUnmaskedText(), "123");
    });

    test('Insert - Incorrect symbols', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      final TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
      expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
    });

    test('Remove - Part - 1', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: const TextSelection(baseOffset: 5, extentOffset: 7));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "+0 (1) 456-78-90", selection: TextSelection.collapsed(offset: 5)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (145) 678-90", selection: TextSelection.collapsed(offset: 5)));
      expect(maskTextInputFormatter.isFill(), false);
      expect(maskTextInputFormatter.getMaskedText(), "+0 (145) 678-90");
      expect(maskTextInputFormatter.getUnmaskedText(), "014567890");
    });

    test('Remove - Part - 2', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "(###) ###-##-##");
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "2555555", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: const TextSelection.collapsed(offset: 11));

      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "(255) 555-", selection: TextSelection.collapsed(offset: 10)));
      expect(currentTextEditingValue, const TextEditingValue(text: "(255) 555", selection: TextSelection.collapsed(offset: 9)));

      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "(255) 55", selection: TextSelection.collapsed(offset: 8)));
      expect(currentTextEditingValue, const TextEditingValue(text: "(255) 55", selection: TextSelection.collapsed(offset: 8)));
    });

    test('Remove - Part - 3', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: const TextSelection(baseOffset: 5, extentOffset: 10));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "+0 (156-78-90", selection: TextSelection.collapsed(offset: 5)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (156) 789-0", selection: TextSelection.collapsed(offset: 5)));
      expect(maskTextInputFormatter.isFill(), false);
      expect(maskTextInputFormatter.getMaskedText(), "+0 (156) 789-0");
      expect(maskTextInputFormatter.getUnmaskedText(), "01567890");
    });

    test('Remove - Part - 4', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "###");
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "123", selection: TextSelection.collapsed(offset: 3)));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "11", selection: TextSelection.collapsed(offset: 2)));
      expect(currentTextEditingValue, const TextEditingValue(text: "12", selection: TextSelection.collapsed(offset: 2)));
      expect(maskTextInputFormatter.isFill(), false);
      expect(maskTextInputFormatter.getMaskedText(), "12");
      expect(maskTextInputFormatter.getUnmaskedText(), "12");
    });

    test('Remove - All', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue.empty);
      expect(maskTextInputFormatter.isFill(), false);
      expect(maskTextInputFormatter.getMaskedText(), "");
      expect(maskTextInputFormatter.getUnmaskedText(), "");
    });

    test('Replace - Part - 1', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: const TextSelection(baseOffset: 4, extentOffset: 7));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "+0 (132) 456-78-90", selection: TextSelection.collapsed(offset: 7)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (132) 456-78-90", selection: TextSelection.collapsed(offset: 7)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getMaskedText(), "+0 (132) 456-78-90");
      expect(maskTextInputFormatter.getUnmaskedText(), "01324567890");
    });

    test('Replace - Part - 2', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "04321567890", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: const TextSelection(baseOffset: 4, extentOffset: 10));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 10)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 10)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
      expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
    });

    test('Replace - Part - 3', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "12223334455", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "54443332211"));
      expect(currentTextEditingValue, const TextEditingValue(text: "+5 (444) 333-22-11", selection: TextSelection.collapsed(offset: 18)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getMaskedText(), "+5 (444) 333-22-11");
      expect(maskTextInputFormatter.getUnmaskedText(), "54443332211");
    });

    test('Update mask', () {
      const String firstMask = "####-####";
      const String secondMask = "##/##-##/##";

      final MaskTextInputFormatter maskTextInputFormatter = MaskTextInputFormatter(mask: firstMask);
      TextEditingValue currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "12345678"));
      expect(currentTextEditingValue, const TextEditingValue(text: "1234-5678", selection: TextSelection.collapsed(offset: 9)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getMaskedText(), "1234-5678");
      expect(maskTextInputFormatter.getUnmaskedText(), "12345678");

      currentTextEditingValue = maskTextInputFormatter.updateMask(mask: secondMask);
      expect(currentTextEditingValue, const TextEditingValue(text: "12/34-56/78", selection: TextSelection.collapsed(offset: 11)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getMaskedText(), "12/34-56/78");
      expect(maskTextInputFormatter.getUnmaskedText(), "12345678");
    });

    test('Paste - All', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##");
      maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "+12345678901", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter.getMaskedText(), "+1 (234) 567-89-01");
    });

    test('Paste - All by mask', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##");
      maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "+1 (234) 567-89-01", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter.getMaskedText(), "+1 (234) 567-89-01");
    });

    test('Clear', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##");
      maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "+1 (234) 567-89-01", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter.getMaskedText(), "+1 (234) 567-89-01");
      maskTextInputFormatter.clear();
      expect(maskTextInputFormatter.getMaskedText(), "");
    });

    test('Clear - 2', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "###-##-##");
      maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "567-89-01", selection: TextSelection.collapsed(offset: 7)));
      expect(maskTextInputFormatter.getMaskedText(), "567-89-01");
      expect(maskTextInputFormatter.getUnmaskedText(), "5678901");
      maskTextInputFormatter.formatEditUpdate(const TextEditingValue(text: "", selection: TextSelection.collapsed(offset: 0)), const TextEditingValue(text: "5", selection: TextSelection.collapsed(offset: 1)));
      expect(maskTextInputFormatter.getMaskedText(), "5");
      expect(maskTextInputFormatter.getUnmaskedText(), "5");
    });

    test('Format text', () {
      const String phone = "2345678901";
      const String mask = "+1 (###) ###-##-##";
      final maskTextInputFormatter = MaskTextInputFormatter(mask: mask);
      expect(mask, maskTextInputFormatter.getMask());
      final masked = maskTextInputFormatter.maskText(phone);
      expect(masked, "+1 (234) 567-89-01");
      final unmasked = maskTextInputFormatter.unmaskText(masked);
      expect(unmasked, phone);
    });

    test('Disabled mask', () {
      const someText = "someText";
      final maskTextInputFormatter = MaskTextInputFormatter(mask: null);
      TextEditingValue result = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: someText, selection: TextSelection.collapsed(offset: 12)));
      expect(result.text, someText);
      expect(maskTextInputFormatter.getMaskedText(), someText);
      expect(maskTextInputFormatter.getUnmaskedText(), someText);

      maskTextInputFormatter.updateMask(mask: "");
      result = maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: someText, selection: TextSelection.collapsed(offset: 12)));
      expect(result.text, someText);
      expect(maskTextInputFormatter.getMaskedText(), someText);
      expect(maskTextInputFormatter.getUnmaskedText(), someText);
    });

    test('Empty filter', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##", filter: {});
      maskTextInputFormatter.formatEditUpdate(const TextEditingValue(), const TextEditingValue(text: "+1 (234) 567-89-01", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter.getMaskedText(), "");
    });

  });

}

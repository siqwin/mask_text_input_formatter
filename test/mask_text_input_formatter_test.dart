import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {

  group("Mask Text Input Formatter Tests", () {

    test('Typing 1', () {
      const phone = "01234567890";
      const expectResult = "+0 (123) 456-78-90";

      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      var currentTextEditingValue = TextEditingValue.empty;
      for (var i = 0; i < phone.length; i++) {
        currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: currentTextEditingValue.text + phone[i], selection: TextSelection.collapsed(offset: currentTextEditingValue.text.length + 1)));
        expect(expectResult.startsWith(currentTextEditingValue.text), true);
        expect(maskTextInputFormatter.isFill(), i == phone.length - 1);
        expect(maskTextInputFormatter.getUnmaskedText(), phone.substring(0, i + 1));
        expect(maskTextInputFormatter.getMaskedText(), currentTextEditingValue.text);
      }
    });

    test('Typing 2', () {
      const typing = "123";
      const expectResult = "123123";

      final maskTextInputFormatter = MaskTextInputFormatter(mask: "123###");
      var currentTextEditingValue = TextEditingValue.empty;
      for (var i = 0; i < typing.length; i++) {
        currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: currentTextEditingValue.text + typing[i], selection: TextSelection.collapsed(offset: currentTextEditingValue.text.length + 1)));
        expect(expectResult.startsWith(currentTextEditingValue.text), true, reason: "$expectResult not starts with ${currentTextEditingValue.text}");
        expect(maskTextInputFormatter.getUnmaskedText(), typing.substring(0, i + 1));
        expect(maskTextInputFormatter.getMaskedText(), currentTextEditingValue.text);
        expect(maskTextInputFormatter.isFill(), i == typing.length - 1);
      }
    });

    test('Typing 4', () {
      const mask = "0######";
      const typing = "000000";
      const expectResult = "0000000";

      final maskTextInputFormatter = MaskTextInputFormatter(mask: mask);
      var currentTextEditingValue = const TextEditingValue(selection: TextSelection.collapsed(offset: 0));
      for (var i = 0; i < typing.length; i++) {
        currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: currentTextEditingValue.text + typing[i], selection: TextSelection.collapsed(offset: currentTextEditingValue.text.length + 1)));
        expect(expectResult.startsWith(currentTextEditingValue.text), true, reason: "$expectResult not starts with ${currentTextEditingValue.text}");
        expect(maskTextInputFormatter.isFill(), i == typing.length - 1);
        expect(maskTextInputFormatter.getUnmaskedText(), typing.substring(0, i + 1));
        expect(maskTextInputFormatter.getMaskedText(), currentTextEditingValue.text);
      }
    });

    test('Typing 5', () {
      const mask = "###1###";
      const typing = "111111";
      const expectResult = "1111111";

      final maskTextInputFormatter = MaskTextInputFormatter(mask: mask);
      var currentTextEditingValue = const TextEditingValue(selection: TextSelection.collapsed(offset: 0));
      for (var i = 0; i < typing.length; i++) {
        currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: currentTextEditingValue.text + typing[i], selection: TextSelection.collapsed(offset: currentTextEditingValue.text.length + 1)));
        expect(expectResult.startsWith(currentTextEditingValue.text), true, reason: "$expectResult not starts with ${currentTextEditingValue.text}");
        expect(maskTextInputFormatter.isFill(), i == typing.length - 1);
        expect(maskTextInputFormatter.getUnmaskedText(), typing.substring(0, i + 1));
        expect(maskTextInputFormatter.getMaskedText(), currentTextEditingValue.text);
      }
    });

    test('Typing 3', () {
      const typing = "321";
      const expectResult = "123321321";

      final maskTextInputFormatter = MaskTextInputFormatter(mask: "123###321");
      var currentTextEditingValue = TextEditingValue.empty;
      for (var i = 0; i < typing.length; i++) {
        currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue(text: currentTextEditingValue.text + typing[i], selection: TextSelection.collapsed(offset: currentTextEditingValue.text.length + 1)));
        expect(expectResult.startsWith(currentTextEditingValue.text), true, reason: "$expectResult not starts with ${currentTextEditingValue.text}");
        expect(maskTextInputFormatter.getMaskedText(), currentTextEditingValue.text);
        expect(maskTextInputFormatter.getUnmaskedText(), typing.substring(0, i + 1));
        expect(maskTextInputFormatter.isFill(), i == typing.length - 1);
      }
    });

    test('Insert - Start', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      final currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "01234567", selection: TextSelection.collapsed(offset: 8)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-7", selection: TextSelection.collapsed(offset: 14)));
      expect(maskTextInputFormatter.isFill(), false);
      expect(maskTextInputFormatter.getUnmaskedText(), "01234567");
      expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-7");
    });

    test('Insert - End', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "01234567", selection: TextSelection.collapsed(offset: 8)));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-7890", selection: TextSelection.collapsed(offset: 18)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
      expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
    });

    test('Insert - Overflow', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      final currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "01234567890123456", selection: TextSelection.collapsed(offset: 18)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
      expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
    });

    test('Insert - Overflow - 2', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "###");
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "123", selection: TextSelection.collapsed(offset: 3)));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "1234", selection: TextSelection.collapsed(offset: 4)));
      expect(currentTextEditingValue, const TextEditingValue(text: "123", selection: TextSelection.collapsed(offset: 3)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getUnmaskedText(), "123");
      expect(maskTextInputFormatter.getMaskedText(), "123");
    });

    test('Insert - Incorrect symbols', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      final currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 18)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
      expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
    });

    test('Insert without prefix', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+998 (••) ••• •• ••", filter: {"•": RegExp('[0-9]')})
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "909006053", selection: TextSelection.collapsed(offset: 9)));
      expect(maskTextInputFormatter.getUnmaskedText(), "909006053");
      expect(maskTextInputFormatter.getMaskedText(), "+998 (90) 900 60 53");
    });

    test('Remove - Part - 1', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: const TextSelection(baseOffset: 5, extentOffset: 7));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "+0 (1) 456-78-90", selection: TextSelection.collapsed(offset: 5)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (145) 678-90", selection: TextSelection.collapsed(offset: 5)));
      expect(maskTextInputFormatter.isFill(), false);
      expect(maskTextInputFormatter.getUnmaskedText(), "014567890");
      expect(maskTextInputFormatter.getMaskedText(), "+0 (145) 678-90");
    });

    test('Remove - Part - 2', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "(###) ###-##-##");
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "2555555", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: const TextSelection.collapsed(offset: 11));

      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "(255) 555-", selection: TextSelection.collapsed(offset: 10)));
      expect(currentTextEditingValue, const TextEditingValue(text: "(255) 555", selection: TextSelection.collapsed(offset: 9)));
      expect(maskTextInputFormatter.getUnmaskedText(), "255555");
      expect(maskTextInputFormatter.getMaskedText(), "(255) 555");

      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "(255) 55", selection: TextSelection.collapsed(offset: 8)));
      expect(currentTextEditingValue, const TextEditingValue(text: "(255) 55", selection: TextSelection.collapsed(offset: 8)));
      expect(maskTextInputFormatter.getUnmaskedText(), "25555");
      expect(maskTextInputFormatter.getMaskedText(), "(255) 55");
    });

    test('Remove - Part - 3', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: const TextSelection(baseOffset: 5, extentOffset: 10));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "+0 (156-78-90", selection: TextSelection.collapsed(offset: 5)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (156) 789-0", selection: TextSelection.collapsed(offset: 5)));
      expect(maskTextInputFormatter.isFill(), false);
      expect(maskTextInputFormatter.getUnmaskedText(), "01567890");
      expect(maskTextInputFormatter.getMaskedText(), "+0 (156) 789-0");
    });

    test('Remove - Part - 4', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "## ## ##");
      var textEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "123", selection: TextSelection.collapsed(offset: 3)));
      textEditingValue = maskTextInputFormatter.formatEditUpdate(textEditingValue, const TextEditingValue(text: "11", selection: TextSelection.collapsed(offset: 2)));
      expect(textEditingValue, const TextEditingValue(text: "11", selection: TextSelection.collapsed(offset: 2)));
      expect(maskTextInputFormatter.isFill(), false);
      expect(maskTextInputFormatter.getUnmaskedText(), "11");
      expect(maskTextInputFormatter.getMaskedText(), "11");

      textEditingValue = maskTextInputFormatter.formatEditUpdate(textEditingValue, const TextEditingValue(text: "123", selection: TextSelection.collapsed(offset: 3)));
      expect(textEditingValue.text, "12 3");
      expect(maskTextInputFormatter.getUnmaskedText(), "123");
      expect(maskTextInputFormatter.getMaskedText(), "12 3");

      textEditingValue = maskTextInputFormatter.formatEditUpdate(textEditingValue, const TextEditingValue(text: "555555", selection: TextSelection.collapsed(offset: 6)));
      expect(textEditingValue.text, "55 55 55");
      expect(maskTextInputFormatter.getUnmaskedText(), "555555");
      expect(maskTextInputFormatter.getMaskedText(), "55 55 55");

      textEditingValue = maskTextInputFormatter.formatEditUpdate(textEditingValue, const TextEditingValue(text: "555333", selection: TextSelection.collapsed(offset: 6)));
      expect(textEditingValue.text, "55 53 33");
      expect(maskTextInputFormatter.getUnmaskedText(), "555333");
      expect(maskTextInputFormatter.getMaskedText(), "55 53 33");

      textEditingValue = maskTextInputFormatter.formatEditUpdate(textEditingValue, const TextEditingValue(text: "333555", selection: TextSelection.collapsed(offset: 6)));
      expect(textEditingValue.text, "33 35 55");
      expect(maskTextInputFormatter.getUnmaskedText(), "333555");
      expect(maskTextInputFormatter.getMaskedText(), "33 35 55");
    });

    test('Remove - All', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, TextEditingValue.empty);
      expect(maskTextInputFormatter.isFill(), false);
      expect(maskTextInputFormatter.getUnmaskedText(), "");
      expect(maskTextInputFormatter.getMaskedText(), "");
    });

    test('Replace - Part - 1', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "01234567890", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: const TextSelection(baseOffset: 4, extentOffset: 7));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "+0 (132) 456-78-90", selection: TextSelection.collapsed(offset: 7)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (132) 456-78-90", selection: TextSelection.collapsed(offset: 7)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getUnmaskedText(), "01324567890");
      expect(maskTextInputFormatter.getMaskedText(), "+0 (132) 456-78-90");
    });

    test('Replace - Part - 2', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "04321567890", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = TextEditingValue(text: currentTextEditingValue.text, selection: const TextSelection(baseOffset: 4, extentOffset: 10));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "+0 (123456-78-90", selection: TextSelection.collapsed(offset: 10)));
      expect(currentTextEditingValue, const TextEditingValue(text: "+0 (123) 456-78-90", selection: TextSelection.collapsed(offset: 10)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getUnmaskedText(), "01234567890");
      expect(maskTextInputFormatter.getMaskedText(), "+0 (123) 456-78-90");
    });

    test('Replace - Part - 3', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##");
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "12223334455", selection: TextSelection.collapsed(offset: 11)));
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(currentTextEditingValue, const TextEditingValue(text: "54443332211"));
      expect(currentTextEditingValue, const TextEditingValue(text: "+5 (444) 333-22-11", selection: TextSelection.collapsed(offset: 18)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getUnmaskedText(), "54443332211");
      expect(maskTextInputFormatter.getMaskedText(), "+5 (444) 333-22-11");
    });

    test('Update mask', () {
      const firstMask = "####-####";
      const secondMask = "##/##-##/##";

      final maskTextInputFormatter = MaskTextInputFormatter(mask: firstMask);
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "12345678"));
      expect(currentTextEditingValue, const TextEditingValue(text: "1234-5678", selection: TextSelection.collapsed(offset: 9)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getUnmaskedText(), "12345678");
      expect(maskTextInputFormatter.getMaskedText(), "1234-5678");

      currentTextEditingValue = maskTextInputFormatter.updateMask(mask: secondMask);
      expect(currentTextEditingValue, const TextEditingValue(text: "12/34-56/78", selection: TextSelection.collapsed(offset: 11)));
      expect(maskTextInputFormatter.isFill(), true);
      expect(maskTextInputFormatter.getUnmaskedText(), "12345678");
      expect(maskTextInputFormatter.getMaskedText(), "12/34-56/78");
    });

    test('Paste - All', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##")
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "+12345678901", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter.getUnmaskedText(), "2345678901");
      expect(maskTextInputFormatter.getMaskedText(), "+1 (234) 567-89-01");
    });

    test('Paste - All by mask', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##")
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "+1 (234) 567-89-01", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter.getUnmaskedText(), "2345678901");
      expect(maskTextInputFormatter.getMaskedText(), "+1 (234) 567-89-01");
    });

    test('Clear', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##")
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "+1 (234) 567-89-01", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter.getUnmaskedText(), "2345678901");
      expect(maskTextInputFormatter.getMaskedText(), "+1 (234) 567-89-01");
      maskTextInputFormatter.clear();
      expect(maskTextInputFormatter.getUnmaskedText(), "");
      expect(maskTextInputFormatter.getMaskedText(), "");
    });

    test('Clear - 2', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "###-##-##")
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "567-89-01", selection: TextSelection.collapsed(offset: 7)));
      expect(maskTextInputFormatter.getMaskedText(), "567-89-01");
      expect(maskTextInputFormatter.getUnmaskedText(), "5678901");
      maskTextInputFormatter.formatEditUpdate(const TextEditingValue(text: "", selection: TextSelection.collapsed(offset: 0)), const TextEditingValue(text: "5", selection: TextSelection.collapsed(offset: 1)));
      expect(maskTextInputFormatter.getMaskedText(), "5");
      expect(maskTextInputFormatter.getUnmaskedText(), "5");
    });

    test('Format text', () {
      const phone = "2345678901";
      const mask = "+1 (###) ###-##-##";
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
      var currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: someText, selection: TextSelection.collapsed(offset: 12)));
      expect(currentTextEditingValue.text, someText);
      expect(maskTextInputFormatter.getMaskedText(), someText);
      expect(maskTextInputFormatter.getUnmaskedText(), someText);

      maskTextInputFormatter.updateMask(mask: "");
      currentTextEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: someText, selection: TextSelection.collapsed(offset: 12)));
      expect(currentTextEditingValue.text, someText);
      expect(maskTextInputFormatter.getMaskedText(), someText);
      expect(maskTextInputFormatter.getUnmaskedText(), someText);
    });

    test('Empty filter', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-##-##", filter: {})
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "+1 (234) 567-89-01", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter.getMaskedText(), "");
      expect(maskTextInputFormatter.getUnmaskedText(), "");
    });

    test('Eager / Lazy autocompletion', () {
      const mask = '#/#';

      final lazyMaskTextInputFormatter = MaskTextInputFormatter(mask: mask, type: MaskAutoCompletionType.lazy);
      final eagerMaskTextInputFormatter = MaskTextInputFormatter(mask: mask, type: MaskAutoCompletionType.eager);

      var lazyTextEditingValue = lazyMaskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "1", selection: TextSelection.collapsed(offset: 1)));
      var eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "1", selection: TextSelection.collapsed(offset: 1)));

      expect(lazyTextEditingValue.text, '1');
      expect(lazyMaskTextInputFormatter.getUnmaskedText(), '1');
      expect(lazyMaskTextInputFormatter.getMaskedText(), '1');
      expect(eagerTextEditingValue.text, '1/');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), '1');
      expect(eagerMaskTextInputFormatter.getMaskedText(), '1/');

      lazyTextEditingValue = lazyMaskTextInputFormatter.formatEditUpdate(lazyTextEditingValue, const TextEditingValue(text: "12", selection: TextSelection.collapsed(offset: 2)));
      eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(eagerTextEditingValue, const TextEditingValue(text: "1/2", selection: TextSelection.collapsed(offset: 3)));

      expect(lazyTextEditingValue.text, '1/2');
      expect(lazyMaskTextInputFormatter.getUnmaskedText(), '12');
      expect(lazyMaskTextInputFormatter.getMaskedText(), '1/2');
      expect(eagerTextEditingValue.text, '1/2');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), '12');
      expect(eagerMaskTextInputFormatter.getMaskedText(), '1/2');

      lazyTextEditingValue = lazyMaskTextInputFormatter.formatEditUpdate(lazyTextEditingValue, const TextEditingValue(text: "1/", selection: TextSelection.collapsed(offset: 2)));
      eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(eagerTextEditingValue, const TextEditingValue(text: "1/", selection: TextSelection.collapsed(offset: 2)));

      expect(lazyTextEditingValue.text, '1');
      expect(lazyMaskTextInputFormatter.getUnmaskedText(), '1');
      expect(lazyMaskTextInputFormatter.getMaskedText(), '1');
      expect(eagerTextEditingValue.text, '1');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), '1');
      expect(eagerMaskTextInputFormatter.getMaskedText(), '1');

      lazyTextEditingValue = lazyMaskTextInputFormatter.formatEditUpdate(lazyTextEditingValue, const TextEditingValue(text: "", selection: TextSelection.collapsed(offset: 0)));
      eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(eagerTextEditingValue, const TextEditingValue(text: "", selection: TextSelection.collapsed(offset: 0)));

      expect(lazyTextEditingValue.text, '');
      expect(lazyMaskTextInputFormatter.getUnmaskedText(), '');
      expect(lazyMaskTextInputFormatter.getMaskedText(), '');
      expect(eagerTextEditingValue.text, '');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), '');
      expect(eagerMaskTextInputFormatter.getMaskedText(), '');

      lazyTextEditingValue = lazyMaskTextInputFormatter.formatEditUpdate(lazyTextEditingValue, const TextEditingValue(text: "12", selection: TextSelection.collapsed(offset: 2)));
      eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(eagerTextEditingValue, const TextEditingValue(text: "12", selection: TextSelection.collapsed(offset: 2)));

      expect(lazyTextEditingValue.text, '1/2');
      expect(lazyMaskTextInputFormatter.getUnmaskedText(), '12');
      expect(lazyMaskTextInputFormatter.getMaskedText(), '1/2');
      expect(eagerTextEditingValue.text, '1/2');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), '12');
      expect(eagerMaskTextInputFormatter.getMaskedText(), '1/2');

      lazyTextEditingValue = lazyMaskTextInputFormatter.formatEditUpdate(lazyTextEditingValue, const TextEditingValue(text: "", selection: TextSelection.collapsed(offset: 0)));
      eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(eagerTextEditingValue, const TextEditingValue(text: "", selection: TextSelection.collapsed(offset: 0)));

      expect(lazyTextEditingValue.text, '');
      expect(lazyMaskTextInputFormatter.getUnmaskedText(), '');
      expect(lazyMaskTextInputFormatter.getMaskedText(), '');
      expect(eagerTextEditingValue.text, '');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), '');
      expect(eagerMaskTextInputFormatter.getMaskedText(), '');

      lazyTextEditingValue = lazyMaskTextInputFormatter.formatEditUpdate(lazyTextEditingValue, const TextEditingValue(text: "1", selection: TextSelection.collapsed(offset: 1)));
      eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(eagerTextEditingValue, const TextEditingValue(text: "1", selection: TextSelection.collapsed(offset: 1)));

      expect(lazyTextEditingValue.text, '1');
      expect(lazyMaskTextInputFormatter.getUnmaskedText(), '1');
      expect(lazyMaskTextInputFormatter.getMaskedText(), '1');
      expect(eagerTextEditingValue.text, '1/');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), '1');
      expect(eagerMaskTextInputFormatter.getMaskedText(), '1/');

      lazyTextEditingValue = lazyMaskTextInputFormatter.formatEditUpdate(lazyTextEditingValue, const TextEditingValue(text: "", selection: TextSelection.collapsed(offset: 0)));
      eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(eagerTextEditingValue, const TextEditingValue(text: "1", selection: TextSelection.collapsed(offset: 1)));

      expect(lazyTextEditingValue.text, '');
      expect(lazyMaskTextInputFormatter.getUnmaskedText(), '');
      expect(lazyMaskTextInputFormatter.getMaskedText(), '');
      expect(eagerTextEditingValue.text, '1');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), '1');
      expect(eagerMaskTextInputFormatter.getMaskedText(), '1');

      eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(eagerTextEditingValue, const TextEditingValue(text: "12", selection: TextSelection.collapsed(offset: 2)));

      expect(eagerTextEditingValue.text, '1/2');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), '12');
      expect(eagerMaskTextInputFormatter.getMaskedText(), '1/2');

    });

    test('Eager autocompletion 2', () {
      final eagerMaskTextInputFormatter = MaskTextInputFormatter(mask: '####.A', initialText: "1234.A", type: MaskAutoCompletionType.eager, filter: {"#": RegExp('[0-9]'), "A": RegExp('[A|B]')});
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), "1234A");
      expect(eagerMaskTextInputFormatter.getMaskedText(), "1234.A");

      var eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(
        const TextEditingValue(text: "1234.A", selection: TextSelection(baseOffset: 5, extentOffset: 6)),
        const TextEditingValue(text: "1234.", selection: TextSelection(baseOffset: 5, extentOffset: 5))
      );
      expect(eagerTextEditingValue.text, '1234');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), "1234");
      expect(eagerMaskTextInputFormatter.getMaskedText(), "1234");

      eagerTextEditingValue = eagerMaskTextInputFormatter.formatEditUpdate(
        const TextEditingValue(text: "1234.", selection: TextSelection(baseOffset: 4, extentOffset: 5)),
        const TextEditingValue(text: "1234", selection: TextSelection(baseOffset: 4, extentOffset: 4))
      );
      expect(eagerTextEditingValue.text, '1234');
      expect(eagerMaskTextInputFormatter.getUnmaskedText(), "1234");
      expect(eagerMaskTextInputFormatter.getMaskedText(), "1234");
    });

    test('Paste masked text', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "21#######-##")
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "214095276-01", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter.getMaskedText(), "214095276-01");

      final maskTextInputFormatter2 = MaskTextInputFormatter(mask: "#21#########")
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "121409527601", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter2.getMaskedText(), "121409527601");

      final maskTextInputFormatter3 = MaskTextInputFormatter(mask: "#21#########")
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "1", selection: TextSelection.collapsed(offset: 1)))
        ..formatEditUpdate(const TextEditingValue(text: "1", selection: TextSelection.collapsed(offset: 1)), const TextEditingValue(text: "121409527601", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter3.getMaskedText(), "121409527601");

      final maskTextInputFormatter4 = MaskTextInputFormatter(mask: "#21#########")
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "1", selection: TextSelection.collapsed(offset: 1)))
        ..formatEditUpdate(const TextEditingValue(text: "121", selection: TextSelection.collapsed(offset: 3)), const TextEditingValue(text: "121409527601", selection: TextSelection.collapsed(offset: 12)));
      expect(maskTextInputFormatter4.getMaskedText(), "121409527601");
    });

    test('Update Mask Type', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "123-###")
        ..formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "321"));
      expect(maskTextInputFormatter.getMaskedText(), "123-321");

      maskTextInputFormatter.updateMask(mask: "###-555", type: MaskAutoCompletionType.eager);
      expect(maskTextInputFormatter.getMaskedText(), "321-555");
      expect(maskTextInputFormatter.getUnmaskedText(), "321");
    });

    test('Empty formatter', () {
      final maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-####");

      expect(maskTextInputFormatter.getMaskedText(), "");
      expect(maskTextInputFormatter.getUnmaskedText(), "");

      final resultEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue.empty);
      expect(resultEditingValue.text, "");
      expect(maskTextInputFormatter.getMaskedText(), "");
      expect(maskTextInputFormatter.getUnmaskedText(), "");
    });

    test('Cursor position', () {
      var maskTextInputFormatter = MaskTextInputFormatter(mask: "+1 (###) ###-####");
      var resultEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "1", selection: TextSelection.collapsed(offset: 1)));

      expect(maskTextInputFormatter.getMaskedText(), "+1 (1");
      expect(maskTextInputFormatter.getUnmaskedText(), "1");
      expect(resultEditingValue.selection.baseOffset, 5);

      maskTextInputFormatter = MaskTextInputFormatter.eager(mask: "+# (###) ###-####");
      resultEditingValue = maskTextInputFormatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "1", selection: TextSelection.collapsed(offset: 1)));

      expect(maskTextInputFormatter.getMaskedText(), "+1 (");
      expect(maskTextInputFormatter.getUnmaskedText(), "1");
      expect(resultEditingValue.selection.baseOffset, 4);
    });

  });

}

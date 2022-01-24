# mask_text_input_formatter

[![Version](https://img.shields.io/pub/v/mask_text_input_formatter.svg)](https://pub.dev/packages/mask_text_input_formatter) [![Build Status](https://travis-ci.com/siqwin/mask_text_input_formatter.svg?branch=master)](https://travis-ci.com/siqwin/mask_text_input_formatter)  [![codecov](https://codecov.io/gh/siqwin/mask_text_input_formatter/branch/master/graph/badge.svg)](https://codecov.io/gh/siqwin/mask_text_input_formatter) ![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)

The package provides TextInputFormatter for TextField and TextFormField which format the input by a given mask.

![logo](https://user-images.githubusercontent.com/49272216/91583922-88393380-e95a-11ea-85d0-07e1bef1a4c1.png)

## Example

Check 'example' folder for code sample

![example](https://user-images.githubusercontent.com/49272216/91583806-5de77600-e95a-11ea-8b13-7b2b85883513.gif)

## Usage

1. Follow the [install guide](https://pub.dev/packages/mask_text_input_formatter/install)

2. Import the library:

```dart
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
```

3. Create mask formatter:

```dart
var maskFormatter = new MaskTextInputFormatter(
  mask: '+# (###) ###-##-##', 
  filter: { "#": RegExp(r'[0-9]') },
  type: MaskAutoCompletionType.lazy
);
```

4. Set it to text field:

```dart
TextField(inputFormatters: [maskFormatter])
```

## Get value

Get masked text:

```dart
print(maskFormatter.getMaskedText()); // -> "+0 (123) 456-78-90"
```

Get unmasked text:

```dart
print(maskFormatter.getUnmaskedText()); // -> 01234567890
```

## Change the mask

You can use the `updateMask` method to change the mask after the formatter was created:

```dart
var textEditingController = TextEditingController(text: "12345678");
var maskFormatter = new MaskTextInputFormatter(mask: '####-####', filter: { "#": RegExp(r'[0-9]') });

TextField(controller: textEditingController, inputFormatters: [maskFormatter])  // -> "1234-5678"

textEditingController.value = maskFormatter.updateMask(mask: "##-##-##-##"); // -> "12-34-56-78"
```

# mask_text_input_formatter

[![Version](https://img.shields.io/pub/v/mask_text_input_formatter)](https://pub.dartlang.org/packages/mask_text_input_formatter) [![Build Status](https://travis-ci.com/siqwin/mask_text_input_formatter.svg?branch=master)](https://travis-ci.com/siqwin/mask_text_input_formatter)  [![codecov](https://codecov.io/gh/siqwin/mask_text_input_formatter/branch/master/graph/badge.svg)](https://codecov.io/gh/siqwin/mask_text_input_formatter) ![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)

Masked text input formatter for flutter.

![logo](doc/flutter_logo.png)

## Example

![sample](doc/example.gif)

## Usage

Follow install guide:

https://pub.dartlang.org/packages/mask_text_input_formatter#-installing-tab-

Import the library:

```dart
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
```

Create mask formatter:

```dart
var maskFormatter = new MaskTextInputFormatter(mask: '+# (###) ###-##-##', filter: { "#": RegExp(r'[0-9]') });
```

Set it to text field:

```dart
TextField(inputFormatters: [maskFormatter])
```

## Change the mask

You can use the `updateMask` method to change the mask after the formatter was created:

```dart
var textEditingController = TextEditingController(text: "12345678");
var maskFormatter = new MaskTextInputFormatter(mask: '####-####', filter: { "#": RegExp(r'[0-9]') });

TextField(controller: textEditingController, inputFormatters: [maskFormatter])  // -> "1234-5678"

textEditingController.value = maskFormatter.updateMask("##-##-##-##"); // -> "12-34-56-78"
```

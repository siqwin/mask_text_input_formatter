import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {

  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExamplePage(title: 'ExamplePage'),
    );
  }

}

class ExamplePage extends StatefulWidget {

  final String title;

  const ExamplePage({Key key, this.title}) : super(key: key);

  @override
  _ExamplePageState createState() => _ExamplePageState();

}

class _ExampleMask {
  final TextEditingController textController = TextEditingController();
  final MaskTextInputFormatter formatter;
  final FormFieldValidator<String> validator;
  final String hint;
  _ExampleMask({ @required this.formatter, this.validator, @required this.hint });
}

class _ExamplePageState extends State<ExamplePage> {

  final List<_ExampleMask> examples = [
    _ExampleMask(
      formatter: MaskTextInputFormatter(mask: "+# (###) ###-##-##"),
      hint: "+1 (234) 567-89-01"
    ),
    _ExampleMask(
      formatter: MaskTextInputFormatter(mask: "##/##/####"),
      hint: "31/12/2020",
      validator: (value) {
        if (value.isEmpty) {
          return null;
        }
        final components = value.split("/");
        if (components.length == 3) {
          final day = int.tryParse(components[0]);
          final month = int.tryParse(components[1]);
          final year = int.tryParse(components[2]);
          if (day != null && month != null && year != null) {
            final date = DateTime(year, month, day);
            if (date.year == year && date.month == month && date.day == day) {
              return null;
            }
          }
        }
        return "wrong date";
      }
    ),
    _ExampleMask(
      formatter: MaskTextInputFormatter(mask: "(AA) ####-####"),
      hint: "(AB) 1234-5678"
    ),
    _ExampleMask(
      formatter: MaskTextInputFormatter(mask: "####.AAAAAA/####-####"),
      hint: "1234.ABCDEF/2019-2020"
    ),
    _ExampleMask(
      formatter: SpecialMaskTextInputFormatter(),
      hint: "A.1234 or B.123456"
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            for (final example in examples)
              buildTextField(example.textController, example.formatter, example.validator, example.hint),
          ],
        )
      )
    );
  }

  Widget buildTextField(TextEditingController textEditingController, MaskTextInputFormatter textInputFormatter, FormFieldValidator<String> validator, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          TextFormField(
            controller: textEditingController,
            inputFormatters: [const UpperCaseTextFormatter(), textInputFormatter],
            autocorrect: false,
            keyboardType: TextInputType.phone,
            autovalidateMode: AutovalidateMode.always,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              fillColor: Colors.white,
              filled: true,
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
              errorMaxLines: 1
            )
          ),
          Positioned(
            right: 0,
            top: 0,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  child: const Icon(Icons.clear, color: Colors.grey, size: 24),
                  onTap: () => textEditingController.clear()
                ),
              )
            ),
          )
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter implements TextInputFormatter {

  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text?.toUpperCase(), selection: newValue.selection);
  }

}

class SpecialMaskTextInputFormatter extends MaskTextInputFormatter {

  static String maskA = "S.####";
  static String maskB = "S.######";

  SpecialMaskTextInputFormatter({
    String initialText
  }): super(
    mask: maskA,
    filter: {"#": RegExp('[0-9]'), "S": RegExp('[AB]')},
    initialText: initialText
  );

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.startsWith("A")) {
      if (getMask() != maskA) {
        updateMask(mask: maskA);
      }
    } else {
      if (getMask() != maskB) {
        updateMask(mask: maskB);
      }
    }
    return super.formatEditUpdate(oldValue, newValue);
  }

}


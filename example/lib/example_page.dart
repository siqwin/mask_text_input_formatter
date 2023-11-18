import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  ExamplePageState createState() => ExamplePageState();
}

class ExamplePageState extends State<ExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: TextFormField(
          inputFormatters: [
            MaskTextInputFormatter(
              mask: '22_____-_',
              filter: {
                "_": RegExp('[0-9]'),
                "x": RegExp('.*'),
                "X": RegExp('.*'),
              },
            )
          ],
          autocorrect: false,
          autovalidateMode: AutovalidateMode.always,
          decoration: const InputDecoration(
            hintStyle: TextStyle(color: Colors.grey),
            fillColor: Colors.white,
            filled: true,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
            errorMaxLines: 1,
          ),
        ),
      ),
    );
  }
}

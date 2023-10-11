import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// import 'package:mask_text_input_formatter_example/special_mask_textInput_formatter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExamplePage(),
    );
  }
}

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
            // MaskTextInputFormatter(
            //   mask: '21__________', // 211234567891
            //   filter: {
            //     "_": RegExp('.*'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            // MaskTextInputFormatter(
            //   mask: '_______-_', // 1234567-9
            //   filter: {
            //     "_": RegExp('.*'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            // MaskTextInputFormatter(
            //   mask: '+996 _________', // +996 990039301
            //   filter: {
            //     "_": RegExp('.*'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            // MaskTextInputFormatter(
            //   mask: '____ ____ ____ ____', // 1234 1234 1234 1234
            //   filter: {
            //     "_": RegExp('.*'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            MaskTextInputFormatter(
              mask: '21-4____ ____ ____ ____', // 21-41234 1234 1234 1234
              filter: {
                "_": RegExp('.*'),
                "x": RegExp('.*'),
                "X": RegExp('.*'),
              },
            ),
          ],
          autocorrect: false,
          autovalidateMode: AutovalidateMode.always,
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.grey),
            fillColor: Colors.white,
            filled: true,
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
            errorMaxLines: 1,
          ),
        ),
      ),
    );
  }
}

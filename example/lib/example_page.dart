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
            // MaskTextInputFormatter(
            //   mask: '21__________', // 211234567891
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            // MaskTextInputFormatter(
            //   mask: '_______-_', // 1234567-9
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            // MaskTextInputFormatter(
            //   mask: '+996 _________', // +996 990039301
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            // MaskTextInputFormatter(
            //   mask: '____ ____ ____ ____', // 1234 1234 1234 1234
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            // MaskTextInputFormatter(
            //   mask: '21-4____ ____ ____ ____', // 21-41234 1234 1234 1234
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            // --------- MBANK ---------------------

            // MaskTextInputFormatter(
            //   mask: '__________', // 1234567890
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            // MaskTextInputFormatter(
            //   mask: '996_________', // 996990039301
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // ),

            // MaskTextInputFormatter(
            //   mask: '0(___) __ __ __', // 0(990) 03 93 01
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '0_________', // 0123456789
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '____ ____ ____ ____', // 1234 1234 1234 1234
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '_-_____', // 1-23456     // 123456
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '+996_________', // +996990039301    // 990039301
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '0___ __ __ __', // 0990 03 93 01    // 990039301
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '996 ___ __ __ __', // 996 990 03 93 01    // 220039301
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '____________', // 123456789012
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '0069 0001 ______', // 0069 0001 123456 // 123456
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '232_________', // 232123456789 // 123456789
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '1000___', // 1000123 // 123
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '137_ ____ ____ ____', // 1371 1234 1234 1234 // 212341234123
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: 'i______________', // i12345678901234 // 12345678901234
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '238_________', // 238123456789 // 123456789
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '07-90____', // 07-901234 // 1234
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '225_________', // 225123456789 // 123456789
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '118_ ____ ____ ____', // '1181 1234 1234 1234', // 7123412341234
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '00___', // 00123 // 123
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '0 ___ __ __ __', // 0 990 03 93 01 // 0990039301
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask:
            //       '01-_________________', // 01-12345678901234567 // 12345678901234567
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '21__________', // 214095276101 // 4095276101
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '__-______-__', // 12-123456-12 // 1212345612
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '02__/____', // 0212/1234 // 121234
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask:
            //       '__-__-__-___________', // 12-12-12-12345678901 // 12121212345678901
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask:
            //       '__-__-______________', // 12-12-12345678901234 // 12345678901234
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask: '96431084033________', // 9643108403312345678 // 12345678
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            // MaskTextInputFormatter(
            //   mask:
            //       '1062 ____ ____ ____', // 1062 1234 1234 1234 // 9234 1234 1234
            //   filter: {
            //     "_": RegExp('[0-9]'),
            //     "x": RegExp('.*'),
            //     "X": RegExp('.*'),
            //   },
            // )

            MaskTextInputFormatter(
              mask: '22_____-_', // 2212345-6 // 123456
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

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaskTextInputFormatterExample',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExamplePage(title: 'ExamplePage'),
    );
  }
}

class ExamplePage extends StatefulWidget {
  final String title;

  ExamplePage({Key key, this.title}) : super(key: key);

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {

  var textEditingController = TextEditingController();
  var maskTextInputFormatter = MaskTextInputFormatter(mask: "+# (###) ###-##-##", filter: { "#": RegExp(r'[0-9]') });

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.blueAccent, body:
      SafeArea(child:
        Padding(padding: const EdgeInsets.all(16.0), child:
          TextField(controller: textEditingController, inputFormatters: [maskTextInputFormatter], autocorrect: false, keyboardType: TextInputType.phone, decoration:
            InputDecoration(hintText: "+1 (123) 123-45-67", fillColor: Colors.white, filled: true)
          )
        )
      )
    );
  }
}

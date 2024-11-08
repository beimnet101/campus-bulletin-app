// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ViewTextField extends StatefulWidget {
  final String labelText;
  final double bottomMargin;

  const ViewTextField(
      {Key? key, required this.labelText, required this.bottomMargin})
      : super(key: key);

  @override
  _ViewTextFieldState createState() => _ViewTextFieldState();
}

class _ViewTextFieldState extends State<ViewTextField> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: widget.bottomMargin, horizontal: 20.0),
          child: TextField(
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              border: OutlineInputBorder(),
              labelText: widget.labelText,
              labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ),
       
      ],
    );
  }
}

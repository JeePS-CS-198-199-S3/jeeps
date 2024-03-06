import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../style/constants.dart';

class InputTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? type;
  final int? lines;
  final int? limit;

  InputTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.type,
    this.lines,
    this.limit
  });

  int textLength = 0;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: type ?? TextInputType.text,
      inputFormatters: type != null && type == TextInputType.number?<TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ]:[],
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white
          ),
        ),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Constants.primaryColor
            )
        ),
        fillColor: Constants.secondaryColor,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
      maxLines: obscureText? 1:lines,
      maxLength: limit,
    );
  }
}
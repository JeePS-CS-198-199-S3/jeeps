import 'package:flutter/material.dart';

import '../style/constants.dart';

class Button extends StatelessWidget {

  final Function()? onTap;
  final String text;
  final Color color;

  const Button({super.key, required this.onTap, required this.text, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8)
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Constants.defaultPadding),
            child: Text(
              text,
              style: const TextStyle(
                  color: Constants.bgColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
          ),
        ),
      ),
    );
  }
}
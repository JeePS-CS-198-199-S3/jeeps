import 'package:flutter/material.dart';

import '../style/constants.dart';

class Button extends StatelessWidget {

  final Function()? onTap;
  final String text;
  final Color color;
  final isMobile;

  const Button({super.key, required this.onTap, required this.text, this.color = Colors.blue, this.isMobile = false});

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
            padding: EdgeInsets.symmetric(vertical: isMobile?Constants.defaultPadding/6:Constants.defaultPadding),
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
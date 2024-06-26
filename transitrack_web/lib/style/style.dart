import 'package:flutter/cupertino.dart';

import 'constants.dart';

// Primary Text (Legacy Widget, rarely used)

class PrimaryText extends StatelessWidget {
  final double size;
  final FontWeight fontWeight;
  final Color color;
  final String text;
  final double height;
  const PrimaryText(
      {super.key,
      required this.text,
      this.size = 20,
      this.fontWeight = FontWeight.w400,
      this.color = Constants.primary,
      this.height = 1.3});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          height: height,
          fontFamily: 'Roboto',
          fontSize: size,
          fontWeight: fontWeight),
    );
  }
}

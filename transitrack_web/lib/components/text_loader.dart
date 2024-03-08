import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import '../../style/constants.dart';

class TextLoader extends StatelessWidget {
  double width;
  double height;
  TextLoader({
    super.key,
    required this.width,
    required this.height
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.75),
        highlightColor: Colors.white.withOpacity(0.25),
        period: const Duration(seconds: 2),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Constants.defaultPadding),
              color: Colors.grey
          ),
        )
    );
  }
}
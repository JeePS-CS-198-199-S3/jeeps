import 'package:flutter/material.dart';
import '../../style/constants.dart';

class SelectJeepPrompt extends StatelessWidget {
  const SelectJeepPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.defaultPadding),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(Constants.defaultPadding)),
      child: const Row(
        children: [
          Icon(Icons.touch_app_rounded),
          SizedBox(width: Constants.defaultPadding),
          Text("Select a PUV on the map")
        ],
      ),
    );
  }
}

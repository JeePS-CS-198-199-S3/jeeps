import 'package:flutter/material.dart';

import '../../style/constants.dart';

class MobileRouteInfo extends StatefulWidget {
  const MobileRouteInfo({super.key});

  @override
  State<MobileRouteInfo> createState() => _MobileRouteInfoState();
}

class _MobileRouteInfoState extends State<MobileRouteInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Constants.defaultPadding),
                child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select a route",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "press the menu icon at the top left\npart of the screen!",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

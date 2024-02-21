import 'package:flutter/material.dart';

import '../style/constants.dart';

class MobileDashboardUnselected extends StatelessWidget {
  const MobileDashboardUnselected({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
        ),
        Positioned(
          bottom: -50,
          right: -40,
          child: Transform.rotate(
              angle: -15 * 3.1415926535 / 180, // Rotate 45 degrees counter-clockwise (NW direction)
              child: const Icon(Icons.touch_app_rounded, color: Colors.white12, size: 270)
          ),
        ),
      ],
    );
  }
}
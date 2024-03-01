import 'package:flutter/material.dart';

import '../style/constants.dart';

class UnselectedDesktopRouteInfo extends StatelessWidget {
  const UnselectedDesktopRouteInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        margin: const EdgeInsets.all(Constants.defaultPadding),
        padding: const EdgeInsets.all(Constants.defaultPadding),
        decoration: const BoxDecoration(
          color: Constants.secondaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select a route",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: Constants.defaultPadding),
            SizedBox(
              height: 200,
              child: Center(child: CircleAvatar(
                radius: 90,
                backgroundColor: Colors.white38,
                child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Constants.secondaryColor,
                    child: Icon(Icons.touch_app_rounded, color: Colors.white38, size: 50)
                ),
              )),
            ),
            SizedBox(height: Constants.defaultPadding),
          ],
        )
    );
  }
}
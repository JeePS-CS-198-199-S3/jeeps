import 'package:flutter/material.dart';

import '../../style/constants.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a route",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Constants.defaultPadding),
            const SizedBox(
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

            const SizedBox(height: Constants.defaultPadding),

            const Divider(),

            const SizedBox(height: Constants.defaultPadding),

            Container(
              width: double.maxFinite,
              height: 60,
              padding: const EdgeInsets.all(Constants.defaultPadding),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white,
                      width: 2
                  ),
                  borderRadius: BorderRadius.circular(Constants.defaultPadding)
              ),
              child: const Center(child: Text("Welcome to JeePS!"))
            )
          ],
        )
    );
  }
}
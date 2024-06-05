import 'package:flutter/material.dart';

import '../../style/constants.dart';

// This widget is visible when no route is selected.

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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5.5),
              child: Text(
                "Select a route",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: Constants.defaultPadding),
            Stack(children: [
              ClipRect(
                  clipper: TopClipper(),
                  child: const SizedBox(
                      height: 200,
                      child: Stack(children: [
                        Center(
                          child: CircleAvatar(
                            radius: 90,
                            backgroundColor: Colors.white38,
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: Constants.secondaryColor,
                            ),
                          ),
                        ),
                        Center(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                              SizedBox(height: Constants.defaultPadding * 4),
                              Icon(Icons.touch_app_rounded,
                                  color: Colors.white38, size: 40)
                            ]))
                      ]))),
              Column(children: [
                const SizedBox(height: Constants.defaultPadding * 7),
                const Divider(color: Colors.white),
                const SizedBox(height: Constants.defaultPadding),
                Container(
                    width: double.maxFinite,
                    height: 60,
                    padding: const EdgeInsets.all(Constants.defaultPadding),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius:
                            BorderRadius.circular(Constants.defaultPadding)),
                    child: const Center(child: Text("Welcome to JeePS!")))
              ])
            ])
          ],
        ));
  }
}

class TopClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, 100); // Clip to top 120 pixels
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}

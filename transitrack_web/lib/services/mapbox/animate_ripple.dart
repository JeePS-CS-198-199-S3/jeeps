import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_web/models/route_model.dart';
import 'package:transitrack_web/services/int_to_hex.dart';

// Ripple effect for Pings and Reports

class RippleTween extends Tween<double> {
  RippleTween({required double begin, required double end})
      : super(begin: begin, end: end);

  @override
  double lerp(double t) => lerpDouble(begin!, end!, t)!;
}

void animateRipple(MapboxMapController mapController, RouteData? route,
    TickerProvider tick, LatLng myLocation) async {
  Circle? ripple1;
  Circle? ripple2;
  mapController
      .addCircle(CircleOptions(
          geometry: myLocation,
          circleColor: intToHexColor(route!.routeColor),
          circleOpacity: 1,
          circleRadius: 0))
      .then((value) => ripple1 = value);
  mapController
      .addCircle(CircleOptions(
          geometry: myLocation,
          circleColor: intToHexColor(route.routeColor),
          circleOpacity: 1,
          circleRadius: 0))
      .then((value) => ripple2 = value);

  final animationController = AnimationController(
    vsync: tick,
    duration: const Duration(milliseconds: 700),
  );
  final animation = RippleTween(begin: 0, end: 1).animate(CurvedAnimation(
    parent: animationController,
    curve: Curves.easeInOut,
  ));
  final animationController2 = AnimationController(
    vsync: tick,
    duration: const Duration(milliseconds: 1400),
  );
  final animation2 = RippleTween(begin: 0, end: 1).animate(CurvedAnimation(
    parent: animationController2,
    curve: Curves.easeInOut,
  ));

  animation.addListener(() {
    mapController.updateCircle(
        ripple1!,
        CircleOptions(
            circleRadius: (animation.value * 70),
            circleOpacity: 1 - animation.value));
  });

  await Future.delayed(const Duration(milliseconds: 300));

  animation2.addListener(() {
    mapController.updateCircle(
        ripple2!,
        CircleOptions(
            circleRadius: (animation2.value * 70),
            circleOpacity: 1 - animation2.value));
  });

  animation.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      animationController.dispose();
      mapController.removeCircle(ripple1!);
    }
  });

  animation2.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      animationController2.dispose();
      mapController.removeCircle(ripple2!);
    }
  });

  animationController.forward();
  animationController2.forward();
}

// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';

// class LatLngTween extends Tween<LatLng> {
//   LatLngTween({required LatLng begin, required LatLng end})
//       : super(begin: begin, end: end);

//   @override
//   LatLng lerp(double t) => LatLng(
//         lerpDouble(begin!.latitude, end!.latitude, t)!,
//         lerpDouble(begin!.longitude, end!.longitude, t)!,
//       );
// }

// void animateCircleMovement(LatLng from, LatLng to, Circle circle,
//     TickerProvider tick, MapboxMapController mapController) {
//   final animationController = AnimationController(
//     vsync: tick,
//     duration: const Duration(milliseconds: 500),
//   );
//   final animation = LatLngTween(begin: from, end: to).animate(CurvedAnimation(
//     parent: animationController,
//     curve: Curves.easeInOut,
//   ));

//   animation.addListener(() {
//     mapController.updateCircle(
//         circle, CircleOptions(geometry: animation.value));
//   });

//   animation.addStatusListener((status) {
//     if (status == AnimationStatus.completed) {
//       animationController.dispose();
//     }
//   });

//   animationController.forward();
// }

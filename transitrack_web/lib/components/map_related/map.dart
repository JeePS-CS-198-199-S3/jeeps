import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../../config/keys.dart';
import '../../config/map_settings.dart';

class MapWidget extends StatefulWidget {
  final bool isHover;
  const MapWidget({Key? key, required this.isHover}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end}) : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) => LatLng(
    lerpDouble(begin!.latitude, end!.latitude, t)!,
    lerpDouble(begin!.longitude, end!.longitude, t)!,
  );
}


class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  late MapboxMapController _mapController;
  late StreamSubscription<Position> _positionStream;

  late Circle deviceCircle;
  bool deviceInMap = false;

  @override
  void initState() {
    super.initState();
    _listenToDeviceLocation();
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  void _listenToDeviceLocation() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    ).listen((Position position) {
      _updateDeviceCircle(LatLng(position.latitude, position.longitude));
    });
  }

  void _updateDeviceCircle(LatLng latLng) {
    if (deviceInMap) {
      LatLng previousLatLng = deviceCircle.options.geometry as LatLng;
      _animateCircleMovement(previousLatLng, latLng, deviceCircle);
    } else {
      _mapController.addCircle(
          CircleOptions(
              geometry: latLng,
              circleRadius: 5,
              circleColor: deviceCircleColor,
              circleStrokeWidth: 2,
              circleStrokeColor: '#FFFFFF'
          )
      ).then((circle) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, mapStartZoom)
        );
        deviceCircle = circle;
        deviceInMap = true;
      });
    }
  }

  void _animateCircleMovement(LatLng from, LatLng to, Circle circle) {
    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final animation = LatLngTween(begin: from, end: to).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));

    animation.addListener(() {
      _mapController.updateCircle(circle, CircleOptions(geometry: animation.value));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
      }
    });

    animationController.forward();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: Keys.MapBoxKey,
      styleString: Keys.MapBoxNight,
      doubleClickZoomEnabled: false,
      minMaxZoomPreference: MinMaxZoomPreference(mapMinZoom, mapMaxZoom),
      scrollGesturesEnabled: !widget.isHover,
      tiltGesturesEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      onMapCreated: (controller) {
        _onMapCreated(controller);
      },
      initialCameraPosition: CameraPosition(
        target: Keys.MapCenter,
        zoom: mapStartZoom,
      ),
    );
  }
}

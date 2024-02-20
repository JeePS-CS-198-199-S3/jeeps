import 'dart:async';

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

class _MapWidgetState extends State<MapWidget> {
  late MapboxMapController _mapController;
  late StreamSubscription  _positionStream;
  List<Circle> circles = [];
  bool exists = false;

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  void _listenToLocation() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    ).listen((Position position) {
      _updateCircle(LatLng(position.latitude, position.longitude));
    });
  }

  void _updateCircle(LatLng latLng) {
    if (exists) {
      Circle deviceCircle = circles.where((circle) => circle.options.circleColor == deviceCircleColor).first;
      _mapController.updateCircle(deviceCircle, CircleOptions(geometry: latLng));
    } else {
      _mapController.addCircle(
          CircleOptions(
              geometry: latLng,
              circleRadius: 5,
              circleColor: deviceCircleColor,
              circleStrokeWidth: 2,
              circleStrokeColor: '#FFFFFF'
          )
      ).then((circle) => circles.add(circle));
      exists = true;
    }
  }

  @override
  void initState() {
    super.initState();
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
      onStyleLoadedCallback: () {
        _listenToLocation();
      },
      initialCameraPosition: CameraPosition(
        target: Keys.MapCenter,
        zoom: mapStartZoom,
      ),
    );
  }
}

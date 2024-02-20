import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../../config/keys.dart';

class MapWidget extends StatefulWidget {
  final bool isHover;
  const MapWidget({Key? key, required this.isHover}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapboxMapController _mapController;
  List<Circle> circles = [];

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation)
        .then(
          (position) => {
            _updateCircle(LatLng(position.latitude, position.longitude))
          }
        );
  }

  void _updateCircle(LatLng latLng) {

    bool exists = false;

    for (var circle in circles) {
      if (circle.options.circleColor == '#3366FF') {
        exists = true;
        break;
      }
    }

    if (exists) {
      Circle deviceCircle = circles.where((circle) => circle.options.circleColor == '#3366FF').first;
      _mapController.updateCircle(deviceCircle, CircleOptions(geometry: latLng));
      circles.removeWhere((circle) => circle.options.circleColor == '#3366FF');
      circles.add(
          Circle(
              "deviceLocation",
              CircleOptions(
                  geometry: latLng,
                  circleRadius: 5,
                  circleColor: '#3366FF',
                  circleStrokeWidth: 2,
                  circleStrokeColor: '#FFFFFF'
              )
          )
      );
    } else {
      _mapController.addCircle(
          CircleOptions(
              geometry: latLng,
              circleRadius: 5,
              circleColor: '#3366FF',
              circleStrokeWidth: 2,
              circleStrokeColor: '#FFFFFF'
          )
      ).then((circle) => circles.add(circle));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: Keys.MapBoxKey,
      styleString: Keys.MapBoxNight,
      doubleClickZoomEnabled: false,
      minMaxZoomPreference: const MinMaxZoomPreference(14, 19),
      scrollGesturesEnabled: !widget.isHover,
      tiltGesturesEnabled: false,
      compassEnabled: false,
      onMapCreated: (controller) {
        _onMapCreated(controller);
      },
      onStyleLoadedCallback: () {
        _getCurrentLocation();
      },
      initialCameraPosition: CameraPosition(
        target: Keys.MapCenter,
        zoom: 15,
      ),
    );
  }
}

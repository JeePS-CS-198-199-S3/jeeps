import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../../config/keys.dart';

class MapWidget extends StatefulWidget {
  final bool isHover;
  const MapWidget({super.key, required this.isHover});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapboxMapController _mapController;

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
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
    return  MapboxMap(
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
      initialCameraPosition: CameraPosition(
        target: Keys.MapCenter,
        zoom: 15,
      ),
    );
  }
}

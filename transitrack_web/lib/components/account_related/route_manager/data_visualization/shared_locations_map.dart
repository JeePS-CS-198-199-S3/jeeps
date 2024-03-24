import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_web/config/keys.dart';
import 'package:transitrack_web/config/map_settings.dart';
import 'package:transitrack_web/models/ping_model.dart';
import 'package:transitrack_web/models/route_model.dart';
import 'package:transitrack_web/services/int_to_hex.dart';

class SharedLocationsMap extends StatefulWidget {
  final RouteData routeData;
  final List<PingData>? pings;
  final bool isHover;
  final ValueChanged<bool> mapLoaded;
  const SharedLocationsMap(
      {super.key,
      required this.routeData,
      required this.pings,
      required this.isHover,
      required this.mapLoaded});

  @override
  State<SharedLocationsMap> createState() => _SharedLocationsMapState();
}

class _SharedLocationsMapState extends State<SharedLocationsMap> {
  late List<PingData>? _pings;

  late MapboxMapController _mapController;
  late bool _isHover;
  bool mapLoaded = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _pings = widget.pings;
      _isHover = widget.isHover;
    });
  }

  Future<void> addGeojsonCluster() async {
    _mapController.addSource(
        "pings",
        GeojsonSourceProperties(
            data: listToGeoJSON(_pings!), cluster: true, clusterRadius: 50));
    _mapController.addLayer(
        "pings",
        "pings-circles",
        CircleLayerProperties(
            circleColor: intToHexColor(widget.routeData.routeColor),
            circleRadius: [
              Expressions.step,
              [Expressions.get, 'point_count'],
              20,
              100,
              30,
              750,
              40
            ]));
    _mapController
        .addLayer(
            "pings",
            "pings-count",
            const SymbolLayerProperties(
              textField: [Expressions.get, 'point_count_abbreviated'],
              textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
              textSize: 12,
            ))
        .then((value) {
      widget.mapLoaded(true);
      setState(() {
        mapLoaded = true;
      });
    });

    for (int i = 0; i < widget.routeData.routeCoordinates.length; i++) {
      _mapController.addLine(LineOptions(
          lineWidth: 4.0,
          lineColor: intToHexColor(widget.routeData.routeColor),
          lineOpacity: 0.5,
          geometry: i != widget.routeData.routeCoordinates.length - 1
              ? [
                  widget.routeData.routeCoordinates[i],
                  widget.routeData.routeCoordinates[i + 1]
                ]
              : [
                  widget.routeData.routeCoordinates[i],
                  widget.routeData.routeCoordinates[0]
                ]));
    }
  }

  @override
  void didUpdateWidget(covariant SharedLocationsMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_pings != widget.pings) {
      setState(() {
        _pings = widget.pings;
      });

      if (mapLoaded) {
        _mapController.setGeoJsonSource("pings", listToGeoJSON(_pings ?? []));
      }
    }

    if (_isHover != widget.isHover) {
      setState(() {
        _isHover = widget.isHover;
      });
    }
  }

  @override
  dispose() {
    super.dispose();
    _mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: Keys.MapBoxKey,
      styleString: Keys.MapBoxNight,
      doubleClickZoomEnabled: false,
      minMaxZoomPreference: MinMaxZoomPreference(mapMinZoom, mapMaxZoom),
      compassEnabled: true,
      scrollGesturesEnabled: !_isHover,
      zoomGesturesEnabled: !_isHover,
      rotateGesturesEnabled: !_isHover,
      tiltGesturesEnabled: !_isHover,
      compassViewPosition: CompassViewPosition.TopLeft,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onStyleLoadedCallback: () {
        addGeojsonCluster();
      },
      initialCameraPosition: CameraPosition(
        target: Keys.MapCenter,
        zoom: mapStartZoom,
      ),
    );
  }
}

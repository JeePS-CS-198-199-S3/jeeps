import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_web/config/keys.dart';
import 'package:transitrack_web/config/map_settings.dart';
import 'package:transitrack_web/models/jeep_model.dart';
import 'package:transitrack_web/models/route_model.dart';
import 'package:transitrack_web/services/int_to_hex.dart';
import 'package:transitrack_web/services/mapbox/add_image_from_asset.dart';

class JeepHistoricalMap extends StatefulWidget {
  final ValueChanged<bool> mapLoaded;
  final List<JeepData>? jeepHistoricalData;
  final RouteData routeData;
  const JeepHistoricalMap(
      {super.key,
      required this.mapLoaded,
      required this.jeepHistoricalData,
      required this.routeData});

  @override
  State<JeepHistoricalMap> createState() => JeepHistoricalMapState();
}

class JeepHistoricalAndIcon {
  JeepData jeepHistorical;
  Symbol jeepSymbol;

  JeepHistoricalAndIcon(
      {required this.jeepHistorical, required this.jeepSymbol});
}

class JeepHistoricalMapState extends State<JeepHistoricalMap> {
  late MapboxMapController _mapController;
  late List<JeepData>? _jeepHistoricalData;

  List<JeepHistoricalAndIcon> data = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      _jeepHistoricalData = widget.jeepHistoricalData;
    });
  }

  @override
  void didUpdateWidget(covariant JeepHistoricalMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_jeepHistoricalData != widget.jeepHistoricalData) {
      setState(() {
        _jeepHistoricalData = widget.jeepHistoricalData;
      });

      if (_jeepHistoricalData != null && _jeepHistoricalData!.isNotEmpty) {
        _mapController.setGeoJsonSource(
            'jeep-historical', jeepListToGeoJSON(_jeepHistoricalData!));
      } else {
        _mapController.setGeoJsonSource('jeep-historical', {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: Keys.MapBoxKey,
      styleString: Keys.MapBoxNight,
      doubleClickZoomEnabled: false,
      minMaxZoomPreference: MinMaxZoomPreference(mapMinZoom, mapMaxZoom),
      compassEnabled: true,
      compassViewPosition: CompassViewPosition.TopLeft,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onStyleLoadedCallback: () {
        addImageFromAsset(_mapController);
        _mapController.setSymbolIconAllowOverlap(true);
        _mapController.setSymbolTextAllowOverlap(true);
        _mapController.setSymbolIconIgnorePlacement(true);
        _mapController.setSymbolTextIgnorePlacement(true);
        addJeepSymbolLayer(_mapController, widget.routeData.routeColor);
        widget.mapLoaded(true);
      },
      initialCameraPosition: CameraPosition(
        target: Keys.MapCenter,
        zoom: mapStartZoom,
      ),
    );
  }
}

void addJeepSymbolLayer(MapboxMapController mapController, int color) {
  mapController.addSource(
      "jeep-historical", const GeojsonSourceProperties(data: []));
  mapController.addLayer(
      "jeep-historical",
      "jeep-historical-symbols",
      CircleLayerProperties(
          circleRadius: 5, circleColor: intToHexColor(color)));
}

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

  List<PingEntity> pingEntities = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      _pings = widget.pings;
      _isHover = widget.isHover;
    });
  }

  @override
  void didUpdateWidget(covariant SharedLocationsMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_pings != widget.pings) {
      setState(() {
        _pings = widget.pings;
      });

      if (_pings != null) {
        updateMap();
      }
    }

    if (_isHover != widget.isHover) {
      setState(() {
        _isHover = widget.isHover;
      });
    }
  }

  void updateMap() {
    if (pingEntities.isNotEmpty) {
      _mapController
          .removeCircles(pingEntities
              .where((pingEntity) => !_pings!
                  .any((ping) => ping.ping_id == pingEntity.pingData.ping_id))
              .map((pingEntity) => pingEntity.pingCircle))
          .then((value) => pingEntities.removeWhere((pingEntity) => !_pings!
              .any((ping) => ping.ping_id == pingEntity.pingData.ping_id)));
    }
    for (PingData ping in _pings!) {
      if (!pingEntities
          .any((pingEntity) => pingEntity.pingData.ping_id == ping.ping_id)) {
        _mapController
            .addCircle(CircleOptions(
                circleColor: intToHexColor(widget.routeData.routeColor),
                circleOpacity: 0.2,
                circleRadius: 5.0,
                geometry: LatLng(
                    ping.ping_location.latitude, ping.ping_location.longitude)))
            .then((pingCircle) => pingEntities
                .add(PingEntity(pingData: ping, pingCircle: pingCircle)));
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
      scrollGesturesEnabled: !_isHover,
      zoomGesturesEnabled: !_isHover,
      rotateGesturesEnabled: !_isHover,
      tiltGesturesEnabled: !_isHover,
      compassViewPosition: CompassViewPosition.TopLeft,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onStyleLoadedCallback: () {
        widget.mapLoaded(true);
        updateMap();
      },
      initialCameraPosition: CameraPosition(
        target: Keys.MapCenter,
        zoom: mapStartZoom,
      ),
    );
  }
}

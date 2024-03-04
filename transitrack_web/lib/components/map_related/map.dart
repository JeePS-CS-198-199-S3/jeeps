import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_web/services/int_to_hex.dart';

import '../../config/keys.dart';
import '../../config/map_settings.dart';
import '../../config/responsive.dart';
import '../../models/route_model.dart';
import '../../style/constants.dart';

class MapWidget extends StatefulWidget {
  String? apiKey;
  final bool isDrawer;
  final RouteData? route;
  final int configRoute;
  final ValueChanged<LatLng> foundDeviceLocation;
  MapWidget({Key? key, required this.apiKey, required this.isDrawer, required this.route, required this.configRoute, required this.foundDeviceLocation}) : super(key: key);

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
  late RouteData? _value;
  late int _configRoute;

  late MapboxMapController _mapController;
  late StreamSubscription<Position> _positionStream;

  late Circle deviceCircle;
  bool deviceInMap = false;

  late List<LatLng> setRoute;
  List<Circle> circles = [];

  @override
  void initState() {
    super.initState();
    _value = widget.route;
    _configRoute = widget.configRoute;
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if route choice changed
    if (widget.route != _value) {
      _value = widget.route;
      addLine();
    }

    // if route management option was selected
    if (widget.configRoute != _configRoute) {

      // unselected any of the choices
      if (widget.configRoute < 0) {

        // Coming from moving points, we save the new coordinates.
        if (_configRoute == 0) {
          setRoute.clear();
          for (var circle in circles) {
            setRoute.add(circle.options.geometry!);
          }

          for (var circle in circles) {
            _mapController.removeCircle(circle);
          }
          circles.clear();
          if (widget.configRoute == -1) {
            update();
          }
          addLine();
        }

      } else {
        setRoute = widget.route!.routeCoordinates;

        // Move points
        if (widget.configRoute == 0) {
          _mapController.clearLines();
          addPoints();
        } else if (widget.configRoute == 1) {
        } else if (widget.configRoute == 2) {

        }
      }

      _configRoute = widget.configRoute == -2
        ? -1
        : widget.configRoute;

    }
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
    _listenToDeviceLocation();
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
      widget.foundDeviceLocation(latLng);
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

  void errorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Constants.bgColor,
              title: Center(
                  child: Text(
                    message,
                    style: const TextStyle(
                        color: Colors.white
                    ),
                  )
              )
          );
        }
    );
  }

  void update() async {
    try {
      Map<String, dynamic> newAccountSettings = {
        'route_coordinates': setRoute.map((latLng) => GeoPoint(latLng.latitude, latLng.longitude)).toList()
      };

      RouteData.updateRouteFirestore(widget.route!.routeId, newAccountSettings).then((value) {
        errorMessage("Route coordinates updated!");
      });
    } catch (e) {
      errorMessage(e.toString());
    }
  }

  void addLine() {
    _mapController.clearLines();
    if (widget.route != null) {
      _mapController.addLine(
        LineOptions(
          geometry: widget.route!.routeCoordinates,
          lineColor: intToHexColor(widget.route!.routeColor), // Line color
          lineWidth: 4.0, // Line width
        ),
      );
    }
  }

  void addPoints() {
    for (var circle in circles) {
      _mapController.removeCircle(circle);
    }
    circles.clear();

    for (int i = 0; i < setRoute.length; i++) {
      _mapController.addCircle(
        CircleOptions(
          circleRadius: 8.0,
          circleStrokeWidth: 2.0,
          circleColor: intToHexColor(widget.route!.routeColor),
          geometry: setRoute[i],
          circleStrokeColor: '#FFFFFF',
          draggable: true
        )
      ).then((circle) => circles.add(circle));
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapboxMap(
            accessToken: widget.apiKey,
            styleString: Keys.MapBoxNight,
            doubleClickZoomEnabled: false,
            minMaxZoomPreference: MinMaxZoomPreference(mapMinZoom, mapMaxZoom),
            scrollGesturesEnabled: !widget.isDrawer,
            zoomGesturesEnabled: !widget.isDrawer,
            rotateGesturesEnabled: !widget.isDrawer,
            tiltGesturesEnabled: !widget.isDrawer,
            compassEnabled: true,
            compassViewPosition: Responsive.isDesktop(context)
                ? CompassViewPosition.BottomLeft
                : CompassViewPosition.TopRight,
            onMapCreated: (controller) {
              _onMapCreated(controller);
            },
            initialCameraPosition: CameraPosition(
              target: Keys.MapCenter,
              zoom: mapStartZoom,
            )
        ),

        Center(
          child: Text(
            "$_configRoute"
          ),
        )
      ],
    );
  }
}

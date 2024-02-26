import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:mapbox_gl/mapbox_gl.dart';

import '../../../config/keys.dart';
import '../../../config/map_settings.dart';
import '../../../config/responsive.dart';
import '../../../models/route_model.dart';
import '../../../services/int_to_hex.dart';
import '../../../style/constants.dart';
import '../../../style/style.dart';
import '../../button.dart';

class CoordinatesSettings extends StatefulWidget {
  String? apiKey;
  RouteData route;
  CoordinatesSettings({super.key, required this.apiKey, required this.route});

  @override
  State<CoordinatesSettings> createState() => _CoordinatesSettingsState();
}

class _CoordinatesSettingsState extends State<CoordinatesSettings> {
  late MapboxMapController _mapController;
  late List<LatLng> setRoute;
  bool edit = false;
  List<Circle> circles = [];
  List<Line> lines = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      setRoute = widget.route.routeCoordinates;
    });
  }

  // void onCircleTapped(Circle circle) {
  //   setRoute[circle.options.circleStrokeOpacity!.toInt()] = LatLng(circle.options.geometry!.latitude, circle.options.geometry!.longitude);
  //   addLine();
  // }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
    // _mapController.onCircleTapped.add(onCircleTapped);
  }

  void _onMapStyleLoaded() {
    addLine();
    addPoints();
  }

  void addLine() {
    _mapController.clearLines();
    for (int i = 0; i < setRoute.length; i++) {
      _mapController.addLine(
          LineOptions(
            lineWidth: 4.0,
            lineColor: intToHexColor(widget.route.routeColor),
            geometry: i != setRoute.length - 1
                ? [setRoute[i], setRoute[i+1]]
                : [setRoute[i], setRoute[0]],
            // circleStrokeOpacity: i.toDouble(),
          )
      ).then((line) => lines.add(line));
    }
  }

  void addPoints() {
    for (int i = 0; i < setRoute.length; i++) {
      _mapController.addCircle(
        CircleOptions(
          circleRadius: 8.0,
          circleColor: intToHexColor(widget.route.routeColor),
          geometry: setRoute[i],
          circleStrokeColor: '#FFFFFF'
          // circleStrokeOpacity: i.toDouble(),
        )
      ).then((circle) => circles.add(circle));
    }
  }

  void update() async {
    try {
      Map<String, dynamic> newAccountSettings = {
        'route_coordinates': setRoute.map((latLng) => GeoPoint(latLng.latitude, latLng.longitude)).toList()
      };

      RouteData.updateRouteFirestore(widget.route.routeId, newAccountSettings).then((value) => errorMessage("Route coordinates updated!"));
    } catch (e) {
      // pop loading circle
      Navigator.pop(context);
      errorMessage(e.toString());
    }
  }

  void editCoordinates() {
    if (edit) {
      _mapController.clearLines();
      for (var circle in circles) {
        _mapController.updateCircle(
          circle,
          const CircleOptions(
            circleStrokeWidth: 2.0,
            draggable: true
          )
        );
      }
    } else {
      for (var circle in circles) {
        setRoute.clear();
        for (var circle in circles) {
          setRoute.add(circle.options.geometry!);
        }
        _mapController.updateCircle(
            circle,
            const CircleOptions(
              circleStrokeWidth: 0.0,
              draggable: false
            )
        );
      }
      addLine();
    }
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

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Constants.defaultPadding, right: Constants.defaultPadding, bottom: Constants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              PrimaryText(text: "Coordinates", color: Colors.white, size: 40, fontWeight: FontWeight.w700,)
            ],
          ),

          const SizedBox(height: Constants.defaultPadding),

          SizedBox(
            height: Responsive.isDesktop(context)
              ? 500
              : 250
            ,
            width: double.maxFinite,
            child: MapboxMap(
              accessToken: widget.apiKey,
              styleString: Keys.MapBoxNight,
              doubleClickZoomEnabled: false,
              minMaxZoomPreference: MinMaxZoomPreference(mapMinZoom, mapMaxZoom),
              compassEnabled: true,
              scrollGesturesEnabled: Responsive.isDesktop(context)
                ? true
                : !edit
              ,
              compassViewPosition: Responsive.isDesktop(context)
                  ? CompassViewPosition.BottomLeft
                  : CompassViewPosition.TopRight,
              onMapCreated: (controller) {
                _onMapCreated(controller);
              },
              onStyleLoadedCallback: _onMapStyleLoaded,
              initialCameraPosition: CameraPosition(
                target: Keys.MapCenter,
                zoom: mapStartZoom,
              ),
            ),
          ),

          const SizedBox(height: Constants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      edit = !edit;
                    });
                    editCoordinates();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: Constants.defaultPadding),
                    color: edit
                      ? Colors.blue
                      : Colors.blue.withOpacity(0.5)
                    ,
                    child: Center(
                      child: Icon(
                        edit
                        ? Icons.check
                        : Icons.edit
                      ),
                    ),
                  ),
                )
              )
            ],
          ),
          const SizedBox(height: Constants.defaultPadding),

          Button(onTap: update, text: "Save",),

        ],
      ),
    );
  }
}

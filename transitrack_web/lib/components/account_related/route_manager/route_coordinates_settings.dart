import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:mapbox_gl/mapbox_gl.dart';

import '../../../config/keys.dart';
import '../../../config/map_settings.dart';
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
  int selected = -1;
  List<Circle> circles = [];
  List<Line> lines = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      setRoute = widget.route.routeCoordinates;
    });
  }

  void onLineTapped(Line pressedLine) {
    if (selected == 1) {
      int index = lines.indexWhere((line) => pressedLine == line);

      double x = (pressedLine.options.geometry![0].latitude + pressedLine.options.geometry![1].latitude)/2;
      double y = (pressedLine.options.geometry![0].longitude + pressedLine.options.geometry![1].longitude)/2;

      setRoute.insert(index + 1, LatLng(x, y));

      _mapController.clearCircles().then((value) => circles.clear()).then((value) => addPoints());
      _mapController.clearLines().then((value) => lines.clear()).then((value) => addLine());
    }
  }

  void onCircleTapped(Circle pressedCircle) {
    if (selected == 2) {
      int index = circles.indexWhere((circle) => pressedCircle == circle);

      setRoute.removeAt(index);

      addPoints();
      addLine();
    }
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
    _mapController.onLineTapped.add(onLineTapped);
    _mapController.onCircleTapped.add(onCircleTapped);
  }

  void _onMapStyleLoaded() {
    addLine();
    addPoints();
  }

  void addLine() {
    _mapController.clearLines().then((value) => lines.clear());
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
    _mapController.clearCircles().then((value) => circles.clear());
    for (int i = 0; i < setRoute.length; i++) {
      _mapController.addCircle(
        CircleOptions(
          circleRadius: 8.0,
          circleColor: intToHexColor(widget.route.routeColor),
          geometry: setRoute[i],
          circleStrokeColor: '#FFFFFF'
        )
      ).then((circle) => circles.add(circle));
    }
  }

  void update() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator()
          );
        }
    );

    try {
      Map<String, dynamic> newAccountSettings = {
        'route_coordinates': setRoute.map((latLng) => GeoPoint(latLng.latitude, latLng.longitude)).toList()
      };

      RouteData.updateRouteFirestore(widget.route.routeId, newAccountSettings).then((value) {
        Navigator.pop(context);
        errorMessage("Route coordinates updated!");
      }).then((value) => Navigator.pop(context));
    } catch (e) {

      Navigator.pop(context);
      errorMessage(e.toString());
    }
  }

  void addCoordinates() {
    if (selected != 1) {
      setRoute.clear();
      for (var circle in circles) {
        setRoute.add(circle.options.geometry!);
      }
      circles.clear();
      addPoints();
      addLine();
    }
  }

  void editCoordinates() {
    if (selected == 0) {
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
      setRoute.clear();
      for (var circle in circles) {
        setRoute.add(circle.options.geometry!);
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
              PrimaryText(text: "Coordinates", color: Colors.white, size: 40, fontWeight: FontWeight.w700)
            ],
          ),

          const SizedBox(height: Constants.defaultPadding),

          SizedBox(
            height: 450,
            width: double.maxFinite,
            child: MapboxMap(
              accessToken: widget.apiKey,
              styleString: Keys.MapBoxNight,
              doubleClickZoomEnabled: false,
              minMaxZoomPreference: MinMaxZoomPreference(mapMinZoom, mapMaxZoom),
              compassEnabled: true,
              compassViewPosition: CompassViewPosition.BottomLeft,
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
                    if (selected == -1) {
                      setState(() {
                        selected = 0;
                      });
                      editCoordinates();
                    } else if (selected == 0) {
                      setState(() {
                        selected = -1;
                      });
                      editCoordinates();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: Constants.defaultPadding),
                    color: selected == 0
                      ? Color(widget.route.routeColor)
                      : Color(widget.route.routeColor).withOpacity(0.6)
                    ,
                    child: Center(
                      child: Icon(
                        selected == 0
                        ? Icons.check
                        : Icons.edit
                      ),
                    ),
                  ),
                )
              ),
              Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (selected == -1) {
                        setState(() {
                          selected = 1;
                        });
                        addCoordinates();
                      } else if (selected == 1){
                        setState(() {
                          selected = -1;
                        });
                        addCoordinates();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: Constants.defaultPadding),
                      color: selected == 1
                          ? Color(widget.route.routeColor)
                          : Color(widget.route.routeColor).withOpacity(0.5)
                      ,
                      child: Center(
                        child: Icon(
                          selected == 1
                            ? Icons.check
                            : Icons.add
                        ),
                      ),
                    ),
                  )
              ),
              Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (selected == -1) {
                        setState(() {
                          selected = 2;
                        });
                        addCoordinates();
                      } else if (selected == 2){
                        setState(() {
                          selected = -1;
                        });
                        addCoordinates();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: Constants.defaultPadding),
                      color: selected == 2
                          ? Color(widget.route.routeColor)
                          : Color(widget.route.routeColor).withOpacity(0.4)
                      ,
                      child: Center(
                        child: Icon(
                            selected == 2
                                ? Icons.check
                                : Icons.remove
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

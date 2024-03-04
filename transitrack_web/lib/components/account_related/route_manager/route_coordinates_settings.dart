import 'package:flutter/material.dart';

import 'package:mapbox_gl/mapbox_gl.dart';

import '../../../models/route_model.dart';
import '../../../style/constants.dart';
import '../../button.dart';

class CoordinatesSettings extends StatefulWidget {
  final RouteData route;
  final ValueChanged<int> coordConfig;
  CoordinatesSettings({super.key, required this.route, required this.coordConfig});

  @override
  State<CoordinatesSettings> createState() => _CoordinatesSettingsState();
}

class _CoordinatesSettingsState extends State<CoordinatesSettings> {
  late List<LatLng> setRoute;
  int selected = -1;
  List<Circle> circles = [];
  List<Line> lines = [];

  @override
  void initState() {
    super.initState();
  }

  // void onLineTapped(Line pressedLine) {
  //   if (selected == 1) {
  //     int index = lines.indexWhere((line) => pressedLine == line);
  //
  //     double x = (pressedLine.options.geometry![0].latitude + pressedLine.options.geometry![1].latitude)/2;
  //     double y = (pressedLine.options.geometry![0].longitude + pressedLine.options.geometry![1].longitude)/2;
  //
  //     setRoute.insert(index + 1, LatLng(x, y));
  //
  //     _mapController.clearCircles().then((value) => circles.clear()).then((value) => addPoints());
  //     _mapController.clearLines().then((value) => lines.clear()).then((value) => addLine());
  //   }
  // }

  // void onCircleTapped(Circle pressedCircle) {
  //   if (selected == 2) {
  //     int index = circles.indexWhere((circle) => pressedCircle == circle);
  //
  //     setRoute.removeAt(index);
  //
  //     addPoints();
  //     addLine();
  //   }
  // }

  // void _onMapCreated(MapboxMapController controller) {
  //   _mapController = controller;
  //   _mapController.onLineTapped.add(onLineTapped);
  //   _mapController.onCircleTapped.add(onCircleTapped);
  // }

  // void _onMapStyleLoaded() {
  //   addLine();
  //   addPoints();
  // }

  // void addLine() {
  //   _mapController.clearLines().then((value) => lines.clear());
  //   for (int i = 0; i < setRoute.length; i++) {
  //     _mapController.addLine(
  //         LineOptions(
  //           lineWidth: 4.0,
  //           lineColor: intToHexColor(widget.route.routeColor),
  //           geometry: i != setRoute.length - 1
  //               ? [setRoute[i], setRoute[i+1]]
  //               : [setRoute[i], setRoute[0]],
  //           // circleStrokeOpacity: i.toDouble(),
  //         )
  //     ).then((line) => lines.add(line));
  //   }
  // }

  // void addPoints() {
  //   _mapController.clearCircles().then((value) => circles.clear());
  //   for (int i = 0; i < setRoute.length; i++) {
  //     _mapController.addCircle(
  //       CircleOptions(
  //         circleRadius: 8.0,
  //         circleColor: intToHexColor(widget.route.routeColor),
  //         geometry: setRoute[i],
  //         circleStrokeColor: '#FFFFFF'
  //       )
  //     ).then((circle) => circles.add(circle));
  //   }
  // }

  // void addCoordinates() {
  //   if (selected != 1) {
  //     setRoute.clear();
  //     for (var circle in circles) {
  //       setRoute.add(circle.options.geometry!);
  //     }
  //     circles.clear();
  //     addPoints();
  //     addLine();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (selected == -1) {
                      setState(() {
                        selected = 0;
                      });
                      widget.coordConfig(0);
                    } else if (selected == 0) {
                      setState(() {
                        selected = -1;
                      });
                      widget.coordConfig(-1);
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
                              ? Icons.save
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
                      widget.coordConfig(1);
                    } else if (selected == 1){
                      setState(() {
                        selected = -1;
                      });
                      widget.coordConfig(-1);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: Constants.defaultPadding),
                    color: selected == 1
                        ? Color(widget.route.routeColor)
                        : Color(widget.route.routeColor).withOpacity(0.5)
                    ,
                    child: Center(
                      child: selected == 1
                        ? const Icon(Icons.save)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              Text("/"),
                              Icon(Icons.remove)
                            ],
                          )
                    ),
                  ),
                )
            )
          ],
        ),
      ],
    );
  }
}

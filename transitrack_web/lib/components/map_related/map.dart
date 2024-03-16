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
import '../../models/account_model.dart';
import '../../models/jeep_model.dart';
import '../../models/route_model.dart';
import '../../style/constants.dart';
import '../account_related/route_manager/route_manager_options.dart';
import '../right_panel/desktop_route_info.dart';
import '../right_panel/unselected_desktop_route_info.dart';
import '../right_panel/mobile_dashboard_unselected.dart';
import '../right_panel/mobile_route_info.dart';

class MapWidget extends StatefulWidget {
  final bool isDrawer;
  final RouteData? route;
  final List<JeepsAndDrivers>? jeeps;
  final AccountData? currentUserFirestore;
  final ValueChanged<LatLng> foundDeviceLocation;
  final ValueChanged<bool> mapLoaded;
  const MapWidget(
      {Key? key,
      required this.isDrawer,
      required this.route,
      required this.jeeps,
      required this.currentUserFirestore,
      required this.foundDeviceLocation,
      required this.mapLoaded})
      : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) => LatLng(
        lerpDouble(begin!.latitude, end!.latitude, t)!,
        lerpDouble(begin!.longitude, end!.longitude, t)!,
      );
}

class RippleTween extends Tween<double> {
  RippleTween({required double begin, required double end})
      : super(begin: begin, end: end);

  @override
  double lerp(double t) => lerpDouble(begin!, end!, t)!;
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  late RouteData? _value;
  late List<JeepsAndDrivers>? jeeps;
  late LatLng? myLocation;
  late int _configRoute;

  late MapboxMapController _mapController;
  late StreamSubscription<Position> _positionStream;

  late Circle? deviceCircle;

  late List<LatLng> setRoute;
  List<Circle> circles = [];
  List<Line> lines = [];
  List<JeepEntity> jeepEntities = [];

  bool isHover = false;

  JeepEntity? selectedJeep;

  @override
  void initState() {
    super.initState();

    setState(() {
      _value = widget.route;
      jeeps = widget.jeeps;
      _configRoute = -1;
      myLocation = null;
      deviceCircle = null;
    });
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if route choice changed
    if (widget.route != _value) {
      selectedJeep = null;

      if (_value == null) {
        _mapController.onCircleTapped.add(onJeepTapped);
      } else {
        if (widget.route == null) {
          _mapController.onCircleTapped.remove(onJeepTapped);
        }
      }

      setState(() {
        _value = widget.route;
      });

      addLine();

      _mapController
          .removeCircles(
              jeepEntities.map((jeepEntity) => jeepEntity.jeepCircle))
          .then((value) => jeepEntities.clear());
    }

    // jeepney updates
    if (widget.jeeps != jeeps) {
      setState(() {
        jeeps = widget.jeeps;
      });

      updateJeeps();

      if (selectedJeep != null &&
          jeeps != null &&
          jeeps!.any((jeep) =>
              jeep.jeep.device_id ==
              selectedJeep!.jeepAndDriver.jeep.device_id)) {
        setState(() {
          selectedJeep = jeepEntities.firstWhere((jeepEntity) =>
              jeepEntity.jeepAndDriver.jeep.device_id ==
              selectedJeep!.jeepAndDriver.jeep.device_id);
        });
      } else {
        setState(() {
          selectedJeep = null;
        });
      }
    }
  }

  void updateJeeps() {
    List<JeepsAndDrivers>? toUpdate = jeeps;
    if (toUpdate != null) {
      for (JeepsAndDrivers jeep in toUpdate!) {
        int index = jeepEntities.indexWhere((entity) =>
            entity.jeepAndDriver.jeep.device_id == jeep.jeep.device_id);

        if (index != -1) {
          JeepEntity? specificJeepEntity = jeepEntities[index];
          if (specificJeepEntity.jeepAndDriver.driver != null) {
            _animateCircleMovement(
              specificJeepEntity.jeepCircle.options.geometry!,
              LatLng(jeep.jeep.location.latitude, jeep.jeep.location.longitude),
              specificJeepEntity.jeepCircle,
            );

            jeepEntities[index] = JeepEntity(
                jeepAndDriver: jeep, jeepCircle: specificJeepEntity.jeepCircle);
          } else {
            _mapController
                .removeCircle(specificJeepEntity.jeepCircle)
                .then((value) => jeepEntities.removeAt(index));
          }
        } else if (jeep.driver != null) {
          _mapController
              .addCircle(CircleOptions(
                  geometry: LatLng(jeep.jeep.location.latitude,
                      jeep.jeep.location.longitude),
                  circleColor: intToHexColor(widget.route!.routeColor),
                  circleStrokeColor: '#FFFFFF',
                  circleRadius: 7))
              .then((circle) => jeepEntities
                  .add(JeepEntity(jeepAndDriver: jeep, jeepCircle: circle)));
        }
      }
    }
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
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
    setState(() {
      myLocation = latLng;
    });
    if (deviceCircle != null) {
      _animateCircleMovement(
          deviceCircle!.options.geometry as LatLng, latLng, deviceCircle!);
    } else {
      _mapController
          .addCircle(CircleOptions(
              geometry: latLng,
              circleRadius: 5,
              circleColor: deviceCircleColor,
              circleStrokeWidth: 2,
              circleStrokeColor: '#FFFFFF'))
          .then((circle) {
        deviceCircle = circle;
      });
      _mapController
          .animateCamera(CameraUpdate.newLatLngZoom(myLocation!, mapStartZoom));
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
      _mapController.updateCircle(
          circle,
          CircleOptions(
              geometry: animation.value,
              circleOpacity: 1,
              circleStrokeOpacity: 1));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
      }
    });

    animationController.forward();
  }

  void _animateRipple() async {
    Circle? ripple1;
    Circle? ripple2;
    _mapController
        .addCircle(CircleOptions(
            geometry: myLocation,
            circleColor: intToHexColor(_value!.routeColor),
            circleOpacity: 1,
            circleRadius: 0))
        .then((value) => ripple1 = value);
    _mapController
        .addCircle(CircleOptions(
            geometry: myLocation,
            circleColor: intToHexColor(_value!.routeColor),
            circleOpacity: 1,
            circleRadius: 0))
        .then((value) => ripple2 = value);

    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    final animation = RippleTween(begin: 0, end: 1).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
    final animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    final animation2 = RippleTween(begin: 0, end: 1).animate(CurvedAnimation(
      parent: animationController2,
      curve: Curves.easeInOut,
    ));

    animation.addListener(() {
      _mapController.updateCircle(
          ripple1!,
          CircleOptions(
              circleRadius: (animation.value * 70),
              circleOpacity: 1 - animation.value));
    });

    await Future.delayed(const Duration(milliseconds: 300));

    animation2.addListener(() {
      _mapController.updateCircle(
          ripple2!,
          CircleOptions(
              circleRadius: (animation2.value * 70),
              circleOpacity: 1 - animation2.value));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
        _mapController.removeCircle(ripple1!);
      }
    });

    animation2.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController2.dispose();
        _mapController.removeCircle(ripple2!);
      }
    });

    animationController.forward();
    animationController2.forward();
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
                style: const TextStyle(color: Colors.white),
              )));
        });
  }

  void update() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    try {
      Map<String, dynamic> newAccountSettings = {
        'route_coordinates': setRoute
            .map((latLng) => GeoPoint(latLng.latitude, latLng.longitude))
            .toList()
      };

      RouteData.updateRouteFirestore(widget.route!.routeId, newAccountSettings)
          .then((value) => Navigator.pop(context))
          .then((value) => Navigator.pop(context));

      errorMessage("Success!");
    } catch (e) {
      // pop loading circle
      Navigator.pop(context);
      errorMessage(e.toString());
    }
  }

  void addLine() {
    _mapController.clearLines().then((value) => lines.clear());
    if (widget.route != null) {
      for (int i = 0;
          i <
              (_configRoute == -1
                  ? widget.route!.routeCoordinates.length
                  : setRoute.length);
          i++) {
        _mapController
            .addLine(LineOptions(
              lineWidth: 4.0,
              lineColor: intToHexColor(widget.route!.routeColor),
              lineOpacity: 0.5,
              geometry: i !=
                      (_configRoute == -1
                              ? widget.route!.routeCoordinates.length
                              : setRoute.length) -
                          1
                  ? (_configRoute == -1
                      ? [
                          widget.route!.routeCoordinates[i],
                          widget.route!.routeCoordinates[i + 1]
                        ]
                      : [setRoute[i], setRoute[i + 1]])
                  : (_configRoute == -1
                      ? [
                          widget.route!.routeCoordinates[i],
                          widget.route!.routeCoordinates[0]
                        ]
                      : [setRoute[i], setRoute[0]]),
            ))
            .then((line) => lines.add(line));
      }
    }
  }

  void addPoints() {
    for (var circle in circles) {
      _mapController.removeCircle(circle);
    }
    circles.clear();

    for (int i = 0; i < setRoute.length; i++) {
      _mapController
          .addCircle(CircleOptions(
              circleRadius: 8.0,
              circleStrokeWidth: 2.0,
              circleStrokeOpacity: 1,
              circleColor: intToHexColor(widget.route!.routeColor),
              geometry: setRoute[i],
              circleStrokeColor: '#FFFFFF',
              draggable: _configRoute == 0 ? true : false))
          .then((circle) => circles.add(circle));
    }
  }

  void onLineTapped(Line pressedLine) {
    int index = lines.indexWhere((line) => pressedLine == line);

    double x = (pressedLine.options.geometry![0].latitude +
            pressedLine.options.geometry![1].latitude) /
        2;
    double y = (pressedLine.options.geometry![0].longitude +
            pressedLine.options.geometry![1].longitude) /
        2;

    setRoute.insert(index + 1, LatLng(x, y));

    for (var circle in circles) {
      _mapController.removeCircle(circle);
    }
    circles.clear();
    addPoints();
    _mapController
        .clearLines()
        .then((value) => lines.clear())
        .then((value) => addLine());
  }

  void onCircleTapped(Circle pressedCircle) {
    int index = circles.indexWhere((circle) => pressedCircle == circle);

    setRoute.removeAt(index);

    addPoints();
    addLine();
  }

  void onJeepTapped(Circle pressedJeep) {
    if (selectedJeep != null) {
      if (pressedJeep != selectedJeep!.jeepCircle) {
        if (jeepEntities
            .any((jeepEntity) => jeepEntity.jeepCircle == pressedJeep)) {
          setState(() {
            selectedJeep = jeepEntities.firstWhere(
                (jeepEntity) => jeepEntity.jeepCircle == pressedJeep);
          });
        }
      } else {
        setState(() {
          selectedJeep = null;
        });
      }
    } else {
      if (jeepEntities
          .any((jeepEntity) => jeepEntity.jeepCircle == pressedJeep)) {
        setState(() {
          selectedJeep = jeepEntities
              .firstWhere((jeepEntity) => jeepEntity.jeepCircle == pressedJeep);
        });
      }
    }

    for (var jeep in jeepEntities) {
      _mapController.updateCircle(
          jeep.jeepCircle, const CircleOptions(circleStrokeWidth: 0));
    }

    if (selectedJeep != null) {
      _mapController.updateCircle(
          selectedJeep!.jeepCircle, const CircleOptions(circleStrokeWidth: 2));
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
    return Scaffold(
      body: Stack(
        children: [
          Column(children: [
            Expanded(
              child: MapboxMap(
                accessToken: Keys.MapBoxKey,
                styleString: Keys.MapBoxNight,
                doubleClickZoomEnabled: false,
                minMaxZoomPreference:
                    MinMaxZoomPreference(mapMinZoom, mapMaxZoom),
                scrollGesturesEnabled: !widget.isDrawer && !isHover,
                zoomGesturesEnabled: !widget.isDrawer && !isHover,
                rotateGesturesEnabled: !widget.isDrawer && !isHover,
                tiltGesturesEnabled: !widget.isDrawer && !isHover,
                compassEnabled: true,
                compassViewPosition: Responsive.isDesktop(context)
                    ? CompassViewPosition.BottomLeft
                    : CompassViewPosition.TopRight,
                onMapCreated: (controller) {
                  _onMapCreated(controller);
                },
                onStyleLoadedCallback: () {
                  widget.mapLoaded(true);
                  _listenToDeviceLocation();
                },
                initialCameraPosition: CameraPosition(
                  target: Keys.MapCenter,
                  zoom: mapStartZoom,
                ),
                onMapClick: (point, latLng) {
                  if (_configRoute == 1 && !widget.isDrawer && !isHover) {
                    setRoute.add(latLng);

                    addPoints();
                    addLine();
                  }
                },
              ),
            ),
            if (Responsive.isMobile(context))
              Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    color: Constants.secondaryColor,
                  ),
                  child: widget.route == null
                      ? const MobileDashboardUnselected()
                      : MobileRouteInfo(
                          route: _value!,
                          jeeps: jeeps!,
                          selectedJeep: selectedJeep != null
                              ? selectedJeep!.jeepAndDriver
                              : null,
                          user: widget.currentUserFirestore,
                          sendPing: (bool value) async {
                            _mapController.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    myLocation!, mapStartZoom));
                            _animateRipple();

                            await Future.delayed(
                                const Duration(milliseconds: 2000));

                            _animateRipple();
                          },
                          isHover: (bool value) {
                            setState(() {
                              isHover = value;
                            });
                          },
                          myLocation: myLocation))
          ]),
          if (Responsive.isDesktop(context))
            Positioned(
                top: 0,
                right: 0,
                child: Column(
                  children: [
                    if (widget.route == null)
                      MouseRegion(
                          onEnter: (_) => setState(() {
                                isHover = true;
                              }),
                          onExit: (_) => setState(() {
                                isHover = false;
                              }),
                          child: const UnselectedDesktopRouteInfo()),

                    if (widget.route != null)
                      MouseRegion(
                        onEnter: (_) => setState(() {
                          isHover = true;
                        }),
                        onExit: (_) => setState(() {
                          isHover = false;
                        }),
                        child: DesktopRouteInfo(
                          route: _value!,
                          jeeps: jeeps!,
                          selectedJeep: selectedJeep != null
                              ? selectedJeep!.jeepAndDriver
                              : null,
                          user: widget.currentUserFirestore,
                          sendPing: (bool value) async {
                            _mapController.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    myLocation!, mapStartZoom));
                            _animateRipple();

                            await Future.delayed(
                                const Duration(milliseconds: 2000));

                            _animateRipple();
                          },
                          isHover: (bool value) {
                            setState(() {
                              isHover = value;
                            });
                          },
                          myLocation: myLocation,
                        ),
                      ),

                    // Route Manager Dashboard
                    if (widget.route != null &&
                        widget.currentUserFirestore != null &&
                        widget.currentUserFirestore!.account_type == 2 &&
                        widget.currentUserFirestore!.is_verified &&
                        widget.route!.routeId ==
                            widget.currentUserFirestore!.route_id)
                      Container(
                          width: 300,
                          padding:
                              const EdgeInsets.all(Constants.defaultPadding),
                          margin: const EdgeInsets.symmetric(
                              horizontal: Constants.defaultPadding),
                          decoration: const BoxDecoration(
                            color: Constants.secondaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: RouteManagerOptions(
                            route: widget.route!,
                            jeeps: widget.jeeps!,
                            hover: (bool hover) {
                              setState(() {
                                isHover = hover;
                              });
                            },
                            coordConfig: (int coordConfig) {
                              int prev = _configRoute;

                              setState(() {
                                _configRoute = coordConfig;
                              });

                              // unselected any of the choices
                              if (_configRoute < 0) {
                                // Coming from moving points, we save the new coordinates.
                                if (prev == 0) {
                                  setRoute.clear();
                                  for (var circle in circles) {
                                    setRoute.add(circle.options.geometry!);
                                  }

                                  for (var circle in circles) {
                                    _mapController.removeCircle(circle);
                                  }
                                  circles.clear();
                                  if (_configRoute == -1) {
                                    update();
                                  }
                                  addLine();
                                } else if (prev == 1) {
                                  _mapController.onCircleTapped
                                      .remove(onCircleTapped);
                                  _mapController.onLineTapped
                                      .remove(onLineTapped);

                                  for (var circle in circles) {
                                    _mapController.removeCircle(circle);
                                  }
                                  circles.clear();

                                  if (_configRoute == -1) {
                                    update();
                                  }
                                }
                              } else {
                                setRoute = widget.route!.routeCoordinates;

                                // Move points
                                if (_configRoute == 0) {
                                  _mapController.clearLines();
                                  addPoints();
                                }

                                // Add or Remove Points
                                else if (_configRoute == 1) {
                                  _mapController.onLineTapped.add(onLineTapped);
                                  _mapController.onCircleTapped
                                      .add(onCircleTapped);
                                  addPoints();
                                }
                              }

                              if (_configRoute == -2) {
                                _configRoute = -1;
                              }
                            },
                          ))
                  ],
                ))
        ],
      ),
    );
  }
}

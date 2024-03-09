import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/components/right_panel/report_form.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:async';

import '../../models/account_model.dart';
import '../../models/jeep_model.dart';
import '../../models/route_model.dart';
import '../../style/constants.dart';
import '../button.dart';
import 'feedback_form.dart';
import '../../services/eta.dart';
import '../text_loader.dart';
import '../../services/format_time.dart';
import '../select_jeep_prompt.dart';
import 'selected_jeep_info.dart';
import '../../config/responsive.dart';

class MobileRouteInfo extends StatefulWidget {
  final RouteData route;
  final List<JeepData> jeeps;
  final JeepData? selectedJeep;
  final AccountData? user;
  final ValueChanged<bool> isHover;
  final LatLng? myLocation;
  const MobileRouteInfo({super.key,
    required this.route,
    required this.jeeps,
    required this.selectedJeep,
    required this.user,
    required this.isHover,
    required this.myLocation
  });

  @override
  State<MobileRouteInfo> createState() => _MobileRouteInfoState();
}

class _MobileRouteInfoState extends State<MobileRouteInfo> {
  late RouteData _value;
  late List<JeepData> _jeeps;
  late JeepData? _selectedJeep;
  late String? _eta;
  late int operating;
  late int not_operating;
  late LatLng? _myLocation;

  AccountData? driverInfo;
  bool isTapped = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _value = widget.route;
      _jeeps = widget.jeeps;
      _selectedJeep = widget.selectedJeep;
      _myLocation = widget.myLocation;
      operating = widget.jeeps.where((jeep) => jeep.is_active == true).length;
      _eta = null;
      not_operating = widget.jeeps.where((jeep) => jeep.is_active == false).length;
    });

    Timer.periodic(const Duration(seconds: 3), fetchEta);
  }

  void fetchDriverData(String jeep_id) async {
    AccountData? acc = await AccountData.getDriverAccountByJeep(jeep_id);
    setState(() {
      driverInfo = acc;
    });
  }

  void fetchEta(Timer timer) async {
    if (_myLocation != null && _selectedJeep != null) {
      String? time = await eta(
          widget.route.routeCoordinates,
          widget.route.isClockwise,
          _myLocation!,
          LatLng(_selectedJeep!.location.latitude, _selectedJeep!.location.longitude)
      );
      setState(() {
        _eta = time;
      });
    }
  }

  @override
  void didUpdateWidget(covariant MobileRouteInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if route choice changed
    if (widget.route != _value) {
      setState(() {
        _value = widget.route;
      });
    }

    if (widget.myLocation != _myLocation) {
      setState(() {
        _myLocation = widget.myLocation;
      });
    }

    if (widget.selectedJeep != _selectedJeep) {
      if (_selectedJeep != null && widget.selectedJeep != null && _selectedJeep!.device_id != widget.selectedJeep!.device_id) {
        setState(() {
          driverInfo = null;
          _eta = null;
        });
      }

      setState(() {
        _selectedJeep = widget.selectedJeep;
      });

      if (_selectedJeep != null) {
        fetchDriverData(_selectedJeep!.device_id);
      }
    }

    if (widget.jeeps != _jeeps) {
      setState(() {
        _jeeps = widget.jeeps;
        operating = widget.jeeps.where((jeep) => jeep.is_active == true).length;
        not_operating = widget.jeeps.where((jeep) => jeep.is_active == false).length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(Constants.defaultPadding),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _value.routeName,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(width: Constants.defaultPadding),

                        if (_selectedJeep != null)
                          Text(
                            "$operating/${operating+not_operating} operating",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ]
                  ),

                  if (_selectedJeep == null)
                    Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: Constants.defaultPadding/3),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRect(
                                        clipper: TopClipper(),
                                        child: SizedBox(
                                          height: 120,
                                          child: Stack(
                                            children: [
                                              PieChart(
                                                PieChartData(
                                                  sectionsSpace: 0,
                                                  centerSpaceRadius: 50,
                                                  startDegreeOffset: -180,
                                                  sections: [
                                                    PieChartSectionData(
                                                      color: Color(widget.route.routeColor),
                                                      value: operating.toDouble(),
                                                      showTitle: false,
                                                      radius: 10,
                                                    ),
                                                    PieChartSectionData(
                                                      color: Color(widget.route.routeColor).withOpacity(0.1),
                                                      value: not_operating.toDouble(),
                                                      showTitle: false,
                                                      radius: 10,
                                                    ),
                                                    PieChartSectionData(
                                                      color: Colors.transparent,
                                                      value: (not_operating + operating).toDouble(),
                                                      showTitle: false,
                                                      radius: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(height: Constants.defaultPadding),
                                                      RichText(
                                                        textAlign: TextAlign.center,
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: '$operating',
                                                              style: Theme.of(context).textTheme.headline4?.copyWith(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: "/${operating + not_operating}",
                                                              style: Theme.of(context).textTheme.headline4?.copyWith(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.w800,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: '\noperating',
                                                              style: Theme.of(context).textTheme.headline4?.copyWith(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        )
                                    ),
                                  ),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${_value.routeFare} Regular",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${_value.routeFareDiscounted} Discounted",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${formatTime(_value.routeTime)}",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ]
                                  )
                                ]
                            ),
                          ]
                        ),
                        Column(
                          children: [
                            const SizedBox(height: Constants.defaultPadding*4.5),
                            const Divider(color: Colors.white),
                            const SizedBox(height: Constants.defaultPadding/2),
                            const SelectJeepPrompt()
                          ]
                        )
                      ]
                    ),

                  if (_selectedJeep != null)
                    Column(
                        children: [
                          SizedBox(height: Constants.defaultPadding),
                          SelectedJeepInfo(
                              jeep: _selectedJeep!,
                              eta: _eta,
                              driverInfo: driverInfo,
                              user: widget.user,
                              route: _value,
                              isHover: (bool value) {
                                widget.isHover(value);
                              }
                          )
                        ]
                    ),
                ]
            ),
          )
        ),
      ],
    );
  }
}

class TopClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, 110); // Clip to top 120 pixels
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}

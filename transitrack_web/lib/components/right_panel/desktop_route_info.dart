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
import 'selected_jeep_info.dart';
import '../../services/eta.dart';
import '../text_loader.dart';
import '../select_jeep_prompt.dart';
import '../../components/cooldown_button.dart';
import '../../services/send_ping.dart';
import '../../models/ping_model.dart';

class DesktopRouteInfo extends StatefulWidget {
  final RouteData route;
  final List<JeepData> jeeps;
  final JeepData? selectedJeep;
  final AccountData? user;
  final ValueChanged<bool> isHover;
  final LatLng? myLocation;
  const DesktopRouteInfo({super.key, required this.route, required this.user, required this.jeeps, required this.selectedJeep, required this.isHover, required this.myLocation});

  @override
  State<DesktopRouteInfo> createState() => _DesktopRouteInfoState();
}

class _DesktopRouteInfoState extends State<DesktopRouteInfo> {
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
  void didUpdateWidget(covariant DesktopRouteInfo oldWidget) {
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
    return Container(
      width: 300,
      margin: const EdgeInsets.all(Constants.defaultPadding),
      padding: const EdgeInsets.all(Constants.defaultPadding),
      decoration: const BoxDecoration(
        color: Constants.secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.5),
                  child: Text(
                    _value.routeName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ),

              const SizedBox(width: Constants.defaultPadding/2),

              if (widget.user != null)
                Container(
                  padding: const EdgeInsets.all(Constants.defaultPadding/3),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white,
                          width: 2
                      ),
                      borderRadius: BorderRadius.circular(Constants.defaultPadding)
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("SendLoc", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                        const SizedBox(width: Constants.defaultPadding/3),
                        CooldownButton(
                            onPressed: () {
                              sendPing(
                                  PingData(
                                      ping_email: widget.user!.account_email,
                                      ping_location: _myLocation!,
                                      ping_route: _value.routeId
                                  )
                              );
                            },
                            alert: "We have broadcasted your location.",
                            verified: widget.user!.is_verified && _myLocation != null && _value != null,
                            child: _myLocation != null
                                ? const Icon(Icons.location_on, size: 15)
                                : const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  color: Constants.bgColor,
                                )
                            )
                        )
                      ]
                  ),
                )
            ]
          ),

          const SizedBox(height: Constants.defaultPadding),

          Stack(
            children: [
              ClipRect(
                  clipper: TopClipper(),
                  child: SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 70,
                            startDegreeOffset: -180,
                            sections: [
                              PieChartSectionData(
                                color: Color(widget.route.routeColor),
                                value: operating.toDouble(),
                                showTitle: false,
                                radius: 20,
                              ),
                              PieChartSectionData(
                                color: Color(widget.route.routeColor).withOpacity(0.1),
                                value: not_operating.toDouble(),
                                showTitle: false,
                                radius: 20,
                              ),
                              PieChartSectionData(
                                color: Colors.transparent,
                                value: (not_operating + operating).toDouble(),
                                showTitle: false,
                                radius: 20,
                              ),
                            ],
                          ),
                        ),
                        Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: Constants.defaultPadding*3),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$operating',
                                        style: Theme.of(context).textTheme.headline4?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "/${operating + not_operating}",
                                        style: Theme.of(context).textTheme.headline4?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\noperating',
                                        style: Theme.of(context).textTheme.headline4?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
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

              Column(
                children: [
                  const SizedBox(height: Constants.defaultPadding*7),

                  const Divider(),

                  const SizedBox(height: Constants.defaultPadding),

                  if (_selectedJeep == null)
                    const SelectJeepPrompt(),

                  if (_selectedJeep != null)
                    SelectedJeepInfo(
                        jeep: _selectedJeep!,
                        eta: _eta,
                        driverInfo: driverInfo,
                        user: widget.user,
                        route: _value,
                        isHover: (bool value) {
                          widget.isHover(value);
                        }
                    ),
                ]
              )
            ]
          )
        ],
      ),
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
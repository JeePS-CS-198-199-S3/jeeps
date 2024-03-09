import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/components/right_panel/report_form.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:async';

import '../../models/account_model.dart';
import '../../models/jeep_model.dart';
import '../../models/route_model.dart';
import '../../config/responsive.dart';
import '../../style/constants.dart';
import '../button.dart';
import 'feedback_form.dart';
import 'report_form.dart';
import '../../services/eta.dart';
import '../text_loader.dart';
import '../select_jeep_prompt.dart';

class SelectedJeepInfo extends StatefulWidget {
  final JeepData jeep;
  final String? eta;
  final AccountData? driverInfo;
  final AccountData? user;
  final RouteData route;
  final ValueChanged<bool> isHover;
  const SelectedJeepInfo({super.key,
    required this.jeep,
    required this.eta,
    required this.driverInfo,
    required this.user,
    required this.route,
    required this.isHover
  });

  @override
  State<SelectedJeepInfo> createState() => _SelectedJeepInfoState();
}

class _SelectedJeepInfoState extends State<SelectedJeepInfo> {
  late JeepData _jeep;
  late String? _eta;
  late AccountData? _driverInfo;
  late AccountData? _user;
  late RouteData _route;

  bool isTapped = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _jeep = widget.jeep;
      _eta = widget.eta;
      _driverInfo = widget.driverInfo;
      _user = widget.user;
      _route = widget.route;
    });
  }

  @override
  void didUpdateWidget(covariant SelectedJeepInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if route choice changed
    if (widget.jeep != _jeep) {
      setState(() {
        _jeep = widget.jeep;
      });
    }

    if (widget.eta != _eta) {
      setState(() {
        _eta = widget.eta;
      });
    }

    if (widget.driverInfo != _driverInfo) {
      setState (() {
        _driverInfo = widget.driverInfo;
      });
    }

    if (widget.user != _user) {
      setState (() {
        _user = widget.user;
      });
    }

    if (widget.route != _route) {
      setState (() {
        _route = widget.route;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.defaultPadding),
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.white,
              width: 2
          ),
          borderRadius: BorderRadius.circular(Constants.defaultPadding)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: Color(widget.route.routeColor)),
                  const SizedBox(width: Constants.defaultPadding),
                  Text(_jeep.device_id)
                ],
              ),
              Row(
                children: [
                  Text("${_jeep.passenger_count}/${_jeep.max_capacity}"),
                  const SizedBox(width: Constants.defaultPadding/2),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          isTapped = !isTapped;
                        });
                      },
                      child: isTapped
                          ? const Icon(Icons.arrow_drop_down)
                          : const Icon(Icons.arrow_drop_up)
                  ),
                ],
              )
            ],
          ),

          if (_jeep != null && isTapped)
            const Divider(color: Colors.white),

          if (_jeep != null && isTapped)
            SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Driver"),
                              const SizedBox(width: Constants.defaultPadding),
                              if (_driverInfo == null)
                                TextLoader(width: 70, height: 15),
                              if (_driverInfo != null)
                                Text(_driverInfo!.account_name, maxLines: 1, overflow: TextOverflow.ellipsis)
                            ],
                          ),

                          const SizedBox(height: Constants.defaultPadding/2),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("ETA"),
                              const SizedBox(width: Constants.defaultPadding),
                              if (_eta == null)
                                TextLoader(width: 40, height: 15),
                              if (_eta != null)
                                Text(_eta!)
                            ],
                          ),

                          if (_user != null && _user!.is_verified && _driverInfo != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: Constants.defaultPadding),

                                if (Responsive.isDesktop(context))
                                  Row(
                                    children: [
                                      Expanded(child: Button(onTap: () => AwesomeDialog(
                                        dialogType: DialogType.noHeader,
                                        context: (context),
                                        width: 500,
                                        body: MouseRegion(
                                          onEnter: (_) => widget.isHover(true),
                                          onExit: (_) => widget.isHover(false),
                                          child: FeedbackForm(
                                              driver: _driverInfo!,
                                              jeep: _jeep,
                                              route: _route,
                                              user: _user
                                          ),
                                        ),
                                      ).show(), text: 'Feedback', color: Color(widget.route.routeColor))),

                                      const SizedBox(width: Constants.defaultPadding),

                                      Expanded(
                                          child: Button(
                                              onTap: () => AwesomeDialog(
                                                  dialogType: DialogType.noHeader,
                                                  context: (context),
                                                  width: 500,
                                                  body: MouseRegion(
                                                    onEnter: (_) => widget.isHover(true),
                                                    onExit: (_) => widget.isHover(false),
                                                    child: ReportForm(
                                                        driver: _driverInfo!,
                                                        jeep: _jeep,
                                                        route: _route,
                                                        user: _user
                                                    ),
                                                  )
                                              ).show(),
                                              text: 'Report', color: Colors.red[700]!
                                          )
                                      )
                                    ],
                                  )
                              ],
                            )
                        ],
                      )
                    ),

                    if (Responsive.isMobile(context) && _user != null && _user!.is_verified && _driverInfo != null)
                      const SizedBox(width: Constants.defaultPadding),

                    if (Responsive.isMobile(context) && _user != null && _user!.is_verified && _driverInfo != null)
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Button(
                              isMobile: true,
                              onTap: () => AwesomeDialog(
                              dialogType: DialogType.noHeader,
                              context: (context),
                              width: 500,
                              body: MouseRegion(
                                onEnter: (_) => widget.isHover(true),
                                onExit: (_) => widget.isHover(false),
                                child: FeedbackForm(
                                    driver: _driverInfo!,
                                    jeep: _jeep,
                                    route: _route,
                                    user: _user
                                ),
                              ),
                            ).show(), text: 'Feedback', color: Color(widget.route.routeColor)),

                            const SizedBox(height: Constants.defaultPadding/2),

                            Button(
                              isMobile: true,
                              onTap: () => AwesomeDialog(
                                  dialogType: DialogType.noHeader,
                                  context: (context),
                                  width: 500,
                                  body: MouseRegion(
                                    onEnter: (_) => widget.isHover(true),
                                    onExit: (_) => widget.isHover(false),
                                    child: ReportForm(
                                        driver: _driverInfo!,
                                        jeep: _jeep,
                                        route: _route,
                                        user: _user
                                    ),
                                  )
                              ).show(),
                              text: 'Report', color: Colors.red[700]!
                            )
                          ],
                        )
                      )
                  ]
                )
              ),
            )
        ],
      ),
    );
  }
}

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:transitrack_web/components/right_panel/report_form.dart';

import '../../models/account_model.dart';
import '../../models/jeep_model.dart';
import '../../models/route_model.dart';
import '../../config/responsive.dart';
import '../../style/constants.dart';
import '../button.dart';
import 'feedback_form.dart';
import '../text_loader.dart';

class SelectedJeepInfo extends StatefulWidget {
  final JeepsAndDrivers jeep;
  final String? eta;
  final AccountData? user;
  final RouteData route;
  const SelectedJeepInfo(
      {super.key,
      required this.jeep,
      required this.eta,
      required this.user,
      required this.route});

  @override
  State<SelectedJeepInfo> createState() => _SelectedJeepInfoState();
}

class _SelectedJeepInfoState extends State<SelectedJeepInfo> {
  late JeepsAndDrivers _jeep;
  late String? _eta;
  late AccountData? _user;
  late RouteData _route;

  bool isTapped = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _jeep = widget.jeep;
      _eta = widget.eta;
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

    if (widget.user != _user) {
      setState(() {
        _user = widget.user;
      });
    }

    if (widget.route != _route) {
      setState(() {
        _route = widget.route;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.defaultPadding),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(Constants.defaultPadding)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: Color(widget.route.routeColor)),
                  const SizedBox(width: Constants.defaultPadding),
                  Text(_jeep.jeep.device_id)
                ],
              ),
              Row(
                children: [
                  if (_jeep.jeep.passenger_count != -2)
                  Text(
                      _jeep.jeep.passenger_count == -1
                      ? "Available"
                      : _jeep.jeep.passenger_count == _jeep.jeep.max_capacity
                        ? "Full"
                        : "${_jeep.jeep.passenger_count}/${_jeep.jeep.max_capacity}"),
                  if (_jeep.jeep.passenger_count != -2)
                  const SizedBox(width: Constants.defaultPadding / 2),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          isTapped = !isTapped;
                        });
                      },
                      child: isTapped
                          ? const Icon(Icons.arrow_drop_down)
                          : const Icon(Icons.arrow_drop_up)),
                ],
              )
            ],
          ),
          if (isTapped) const Divider(color: Colors.white),
          if (isTapped)
            SizedBox(
                width: double.maxFinite,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 4,
                          child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Driver"),
                                      if (_jeep.driver == null)
                                        TextLoader(width: 70, height: 15),
                                      if (_jeep.driver != null)
                                        Text(_jeep.driver!.account_name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis)
                                    ],
                                  ),
                                  const SizedBox(
                                      height: Constants.defaultPadding / 2),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("ETA"),
                                      if (_eta == null)
                                        TextLoader(width: 40, height: 15),
                                      if (_eta != null) Text(_eta!)
                                    ],
                                  ),
                                  if (_user != null &&
                                      _user!.is_verified &&
                                      _jeep.driver != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                            height: Constants.defaultPadding),
                                        if (Responsive.isDesktop(context))
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Button(
                                                      onTap: () =>
                                                          AwesomeDialog(
                                                            dialogType:
                                                                DialogType
                                                                    .noHeader,
                                                            context: (context),
                                                            width: 500,
                                                            body: FeedbackForm(
                                                                jeep: _jeep,
                                                                route: _route,
                                                                user: _user),
                                                          ).show(),
                                                      text: 'Feedback',
                                                      color: Color(widget
                                                          .route.routeColor))),
                                              const SizedBox(
                                                  width:
                                                      Constants.defaultPadding),
                                              Expanded(
                                                  child: Button(
                                                      onTap: () =>
                                                          AwesomeDialog(
                                                            dialogType:
                                                                DialogType
                                                                    .noHeader,
                                                            context: (context),
                                                            width: 500,
                                                            body: ReportForm(
                                                                jeep: _jeep,
                                                                route: _route,
                                                                user: _user),
                                                          ).show(),
                                                      text: 'Report',
                                                      color: Colors.red[700]!))
                                            ],
                                          )
                                      ],
                                    )
                                ],
                              ))),
                      if (Responsive.isMobile(context) &&
                          _user != null &&
                          _user!.is_verified &&
                          _jeep.driver != null)
                        const SizedBox(width: Constants.defaultPadding),
                      if (Responsive.isMobile(context) &&
                          _user != null &&
                          _user!.is_verified &&
                          _jeep.driver != null)
                        Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Button(
                                    isMobile: true,
                                    onTap: () {
                                      AwesomeDialog(
                                        dialogType: DialogType.noHeader,
                                        context: (context),
                                        width: 500,
                                        body: PointerInterceptor(
                                          child: FeedbackForm(
                                              jeep: _jeep,
                                              route: _route,
                                              user: _user),
                                        ),
                                      ).show();
                                    },
                                    text: 'Feedback',
                                    color: Color(widget.route.routeColor)),
                                const SizedBox(
                                    height: Constants.defaultPadding / 2),
                                Button(
                                    isMobile: true,
                                    onTap: () {
                                      AwesomeDialog(
                                        dialogType: DialogType.noHeader,
                                        context: (context),
                                        width: 500,
                                        body: PointerInterceptor(
                                          child: ReportForm(
                                              jeep: _jeep,
                                              route: _route,
                                              user: _user),
                                        ),
                                      ).show();
                                    },
                                    text: 'Report',
                                    color: Colors.red[700]!)
                              ],
                            ))
                    ]))
        ],
      ),
    );
  }
}

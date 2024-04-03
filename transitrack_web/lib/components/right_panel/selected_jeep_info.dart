import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:transitrack_web/components/icon_button_big.dart';
import 'package:transitrack_web/components/right_panel/report_form.dart';
import 'package:transitrack_web/models/feedback_model.dart';

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

  double? jeepRating;
  double? driverRating;

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

    loadRatings();
  }

  @override
  void didUpdateWidget(covariant SelectedJeepInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if route choice changed
    if (widget.jeep != _jeep) {
      if (_jeep.jeep.device_id != widget.jeep.jeep.device_id) {
        loadRatings();
      }
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

  void loadRatings() async {
    setState(() {
      driverRating = null;
      jeepRating = null;
    });
    var data1 =
        await getRating(_jeep.driver!.account_email, 'feedback_recepient');
    var data2 = await getRating(_jeep.jeep.device_id, 'feedback_jeepney');

    setState(() {
      driverRating = (data1!
              .map((e) => e.feedback_driving_rating)
              .toList()
              .reduce((value, element) => value + element) /
          data1.length);
      jeepRating = (data2!
              .map((e) => e.feedback_jeepney_rating)
              .toList()
              .reduce((value, element) => value + element) /
          data2.length);
    });
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
          if (_jeep.jeep.passenger_count == -2)
            const SelectedJeepInfoRow(
                left: Text("Driver disabled passenger counting.",
                    style: TextStyle(fontSize: 12)),
                right: SizedBox()),
          if (_jeep.jeep.passenger_count != -2)
            SelectedJeepInfoRow(
                left: Row(
                  children: [
                    Icon(Icons.supervisor_account,
                        color: Color(widget.route.routeColor), size: 15),
                    const SizedBox(width: Constants.defaultPadding / 2),
                    const Text("Occupancy"),
                  ],
                ),
                right: Text(_jeep.jeep.passenger_count == -1
                    ? "Available"
                    : _jeep.jeep.passenger_count == _jeep.jeep.max_capacity
                        ? "Full"
                        : "${_jeep.jeep.passenger_count}/${_jeep.jeep.max_capacity}")),
          const Divider(color: Colors.white),
          SelectedJeepInfoRow(
              left: Row(children: [
                Text(jeepRating != null
                    ? double.parse(jeepRating.toString()).toStringAsFixed(1)
                    : "..."),
                const SizedBox(
                  width: Constants.defaultPadding / 2,
                ),
                Icon(Icons.star,
                    color: Color(widget.route.routeColor), size: 15),
                const SizedBox(
                  width: Constants.defaultPadding / 2,
                ),
                const Text("Plate Number")
              ]),
              right: Text(_jeep.jeep.device_id)),
          const Divider(color: Colors.white),
          SelectedJeepInfoRow(
              left: Row(children: [
                Text(driverRating != null
                    ? double.parse(driverRating.toString()).toStringAsFixed(1)
                    : "..."),
                const SizedBox(
                  width: Constants.defaultPadding / 2,
                ),
                Icon(Icons.star,
                    color: Color(widget.route.routeColor), size: 15),
                const SizedBox(
                  width: Constants.defaultPadding / 2,
                ),
                const Text("Driver"),
                const SizedBox(width: Constants.defaultPadding / 2),
              ]),
              right: Text(_jeep.driver!.account_name,
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
          const Divider(color: Colors.white),
          SelectedJeepInfoRow(
              left: Row(children: [
                Icon(Icons.timelapse_rounded,
                    color: Color(widget.route.routeColor), size: 15),
                const SizedBox(
                  width: Constants.defaultPadding / 2,
                ),
                const Text("ETA")
              ]),
              right: Text(_eta ?? "...")),
          const Divider(color: Colors.white),
          if (_user != null && _user!.is_verified && _jeep.driver != null)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconButtonBig(
                  color: Color(widget.route.routeColor),
                  function: () => AwesomeDialog(
                        dialogType: DialogType.noHeader,
                        context: (context),
                        width: 500,
                        body: PointerInterceptor(
                            child: FeedbackForm(
                                jeep: _jeep, route: _route, user: _user)),
                      ).show(),
                  icon: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Constants.bgColor, size: 20),
                      SizedBox(width: Constants.defaultPadding / 5),
                      Text(
                        "Feedback",
                        style: TextStyle(color: Constants.bgColor),
                      )
                    ],
                  )),
              const SizedBox(width: Constants.defaultPadding / 2),
              IconButtonBig(
                  inverted: true,
                  color: Color(widget.route.routeColor),
                  function: () => AwesomeDialog(
                        dialogType: DialogType.noHeader,
                        context: (context),
                        width: 500,
                        body: PointerInterceptor(
                            child: ReportForm(
                                jeep: _jeep, route: _route, user: _user)),
                      ).show(),
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.report_outlined,
                          color: Color(widget.route.routeColor), size: 20),
                      const SizedBox(width: Constants.defaultPadding / 5),
                      Text(
                        "Report",
                        style: TextStyle(color: Color(widget.route.routeColor)),
                      )
                    ],
                  ))
            ])
        ],
      ),
    );
  }
}

class SelectedJeepInfoRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  const SelectedJeepInfoRow(
      {super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [left, right]);
  }
}

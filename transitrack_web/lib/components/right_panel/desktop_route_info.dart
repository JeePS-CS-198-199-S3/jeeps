import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/account_model.dart';
import '../../models/jeep_model.dart';
import '../../models/route_model.dart';
import '../../style/constants.dart';
import '../button.dart';
import 'feedback_form.dart';

class DesktopRouteInfo extends StatefulWidget {
  final RouteData route;
  final List<JeepData> jeeps;
  final JeepData? selectedJeep;
  final AccountData? user;
  final ValueChanged<bool> isHover;
  const DesktopRouteInfo({super.key, required this.route, required this.user, required this.jeeps, required this.selectedJeep, required this.isHover});

  @override
  State<DesktopRouteInfo> createState() => _DesktopRouteInfoState();
}

class _DesktopRouteInfoState extends State<DesktopRouteInfo> {
  late RouteData _value;
  late List<JeepData> _jeeps;
  late JeepData? _selectedJeep;
  late int operating;
  late int not_operating;

  AccountData? driverInfo;
  bool isTapped = false;

 void fetchDriverData(String jeep_id) async {
   AccountData? acc = await AccountData.getDriverAccountByJeep(jeep_id);
    setState(() {
      driverInfo = acc;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _value = widget.route;
      _jeeps = widget.jeeps;
      _selectedJeep = widget.selectedJeep;
      operating = widget.jeeps.where((jeep) => jeep.is_active == true).length;
      not_operating = widget.jeeps.where((jeep) => jeep.is_active == false).length;
    });
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

    if (widget.selectedJeep != _selectedJeep) {
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
          Text(
            _value.routeName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: Constants.defaultPadding),

          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 70,
                    startDegreeOffset: -90,
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
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$operating',
                              style: Theme.of(context).textTheme.headline4?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: "/${operating + not_operating}",
                              style: Theme.of(context).textTheme.headline4?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
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
                      const SizedBox(height: Constants.defaultPadding),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Constants.defaultPadding),

          const Divider(),

          const SizedBox(height: Constants.defaultPadding),

          if (widget.selectedJeep == null)
            Container(
            padding: const EdgeInsets.all(Constants.defaultPadding),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2
              ),
              borderRadius: BorderRadius.circular(Constants.defaultPadding)
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app_rounded),
                SizedBox(width: Constants.defaultPadding),
                Text("Select a jeepney")
              ],
            ),
          ),

          if (widget.selectedJeep != null)
            Container(
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
                          Text(widget.selectedJeep!.device_id)
                        ],
                      ),
                      Row(
                        children: [
                          Text("${widget.selectedJeep!.passenger_count}/${widget.selectedJeep!.max_capacity}"),
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

                  if (widget.selectedJeep != null && isTapped)
                    const Divider(color: Colors.white),

                  if (widget.selectedJeep != null && isTapped)
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Driver"),
                              const SizedBox(width: Constants.defaultPadding),
                              Text(driverInfo != null ? driverInfo!.account_name : "Unassigned", maxLines: 1, overflow: TextOverflow.ellipsis,)
                            ],
                          ),

                          if (widget.user != null && widget.user!.is_verified && driverInfo != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: Constants.defaultPadding),

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
                                        driver: driverInfo!,
                                        jeep: _selectedJeep!,
                                        route: widget.route,
                                        user: widget.user),
                                    ),
                                  ).show(), text: 'Feedback', color: Color(widget.route.routeColor))),

                                  const SizedBox(width: Constants.defaultPadding),

                                  Expanded(child: Button(onTap: () {

                                  }, text: 'Report', color: Colors.red[700]!)),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
        ],
      ),
    );
  }
}

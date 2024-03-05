import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/jeep_model.dart';
import '../models/route_model.dart';
import '../style/constants.dart';

class DesktopRouteInfo extends StatefulWidget {
  final RouteData route;
  final List<JeepData> jeeps;
  final JeepData? selectedJeep;
  const DesktopRouteInfo({super.key, required this.route, required this.jeeps, required this.selectedJeep});

  @override
  State<DesktopRouteInfo> createState() => _DesktopRouteInfoState();
}

class _DesktopRouteInfoState extends State<DesktopRouteInfo> {
  late RouteData _value;
  late List<JeepData> _jeeps;
  late int operating;
  late int not_operating;

  @override
  void initState() {
    super.initState();
    setState(() {
      _value = widget.route;
      _jeeps = widget.jeeps;
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, color: Color(widget.route.routeColor)),
                      const SizedBox(width: Constants.defaultPadding),
                      Text(widget.selectedJeep!.device_id)
                    ],
                  ),
                  const Icon(Icons.arrow_drop_up)
                ],
              ),
            ),
        ],
      ),
    );
  }
}

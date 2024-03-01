import 'package:flutter/material.dart';
import 'package:transitrack_web/components/account_related/route_manager/route_properties_settings.dart';
import '../../../config/responsive.dart';
import '../../../models/route_model.dart';
import '../../../style/constants.dart';

class RouteManagerOptions extends StatefulWidget {
  String? apiKey;
  final RouteData route;
  RouteManagerOptions({super.key, required this.apiKey, required this.route});

  @override
  State<RouteManagerOptions> createState() => _RouteManagerOptionsState();
}

class _RouteManagerOptionsState extends State<RouteManagerOptions> {
  int selected = -1;
  String optionTitle = "Route Management";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              optionTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            if (selected != -1)
              GestureDetector(
                onTap: () => setState(() {
                  selected = -1;
                  optionTitle = "Route Management";
                }),
                child: const Icon(
                  Icons.keyboard_backspace_outlined,
                )
              )
          ],
        ),

        const SizedBox(height: Constants.defaultPadding),

        if (selected == -1)
          Row(
            children: [
              // Route Manager Properties
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      selected = 0;
                      optionTitle = "Properties";
                    });
                  },
                  child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: selected == 0
                            ? Color(widget.route.routeColor)
                            : Color(widget.route.routeColor).withOpacity(0.6),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              Icons.account_tree
                          ),
                          Text(
                            "Properties",
                            style: TextStyle(
                              fontSize: 10,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      )
                  ),
                ),
              ),


              // Route Manager Coordinates
              Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      selected = 1;
                      optionTitle = "Coordinates";
                    },
                    child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: selected == 1
                              ? Color(widget.route.routeColor)
                              : Color(widget.route.routeColor).withOpacity(0.5),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.line_axis
                            ),
                            Text(
                              "Coordinates",
                              style: TextStyle(
                                fontSize: 10,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        )
                    ),
                  ),
            ),


              // Route Manager Vehicles
              Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      selected = 2;
                      optionTitle = "Vehicles";
                    },
                    child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: selected == 2
                              ? Color(widget.route.routeColor)
                              : Color(widget.route.routeColor).withOpacity(0.4),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.directions_bus
                            ),
                            Text(
                              "Vehicles",
                              style: TextStyle(
                                fontSize: 10,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        )
                    ),
                  ),
                ),
            ],
          ),

        if (selected == 0)
          PropertiesSettings(route: widget.route)
      ],
    );
  }
}

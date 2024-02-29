import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:transitrack_web/components/account_related/route_manager/route_coordinates_settings.dart';
import 'package:transitrack_web/components/account_related/route_manager/route_properties_settings.dart';

import '../../../config/responsive.dart';
import '../../../models/route_model.dart';
import '../../../style/constants.dart';

class RouteManagerOptions extends StatefulWidget {
  String? apiKey;
  final RouteData route;
  final Function() hoverToggle;
  RouteManagerOptions({super.key, required this.apiKey, required this.hoverToggle, required this.route});

  @override
  State<RouteManagerOptions> createState() => _RouteManagerOptionsState();
}

class _RouteManagerOptionsState extends State<RouteManagerOptions> {
  int selected = -1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Constants.defaultPadding),
      child: Row(
        children: [
          // Route Manager Properties
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (Responsive.isDesktop(context)) {widget.hoverToggle();}
                setState(() {
                  selected = 0;
                });
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.noHeader,
                    body: PropertiesSettings(route: widget.route)
                ).show().then((value) {
                  if (Responsive.isDesktop(context)) {widget.hoverToggle();}
                  setState(() {
                    selected = -1;
                  });
                });
              },
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected==0?Color(widget.route.routeColor):Color(widget.route.routeColor).withOpacity(0.6),
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
          if (Responsive.isDesktop(context))
            Expanded(
            child: GestureDetector(
              onTap: () async {
                if (Responsive.isDesktop(context)) {widget.hoverToggle();}
                setState(() {
                  selected = 1;
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      body: CoordinatesSettings(route: widget.route, apiKey: widget.apiKey)
                  ).show().then((value) {
                    if (Responsive.isDesktop(context)) {widget.hoverToggle();}
                    setState(() {
                      selected = -1;
                    });
                  });
                });
              },
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected==1?Color(widget.route.routeColor):Color(widget.route.routeColor).withOpacity(0.5),
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
          if (Responsive.isDesktop(context))
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (Responsive.isDesktop(context)) {widget.hoverToggle();}
                setState(() {
                  selected = 2;
                });
                AwesomeDialog(
                    context: context,
                    dialogType: DialogType.noHeader,
                    body: const Center(child: Text("Vehicles"))
                ).show().then((value) {
                  if (Responsive.isDesktop(context)) {widget.hoverToggle();}
                  setState(() {
                    selected = -1;
                  });
                });
              },
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected==2?Color(widget.route.routeColor):Color(widget.route.routeColor).withOpacity(0.4),
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
    );
  }
}

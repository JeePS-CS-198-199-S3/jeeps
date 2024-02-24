import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../../style/constants.dart';

class RouteManagerOptions extends StatefulWidget {
  final Function() hoverToggle;
  const RouteManagerOptions({super.key, required this.hoverToggle});

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
                widget.hoverToggle();
                setState(() {
                  selected = 0;
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      body: const Center(child: Text("Properties"))
                  ).show().then((value) {
                    widget.hoverToggle();
                    setState(() {
                      selected = -1;
                    });
                  });
                });
              },
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected==0?Colors.blue:Colors.blue.withOpacity(0.6),
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
                widget.hoverToggle();
                setState(() {
                  selected = 0;
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      body: const Center(child: Text("Properties"))
                  ).show().then((value) {
                    widget.hoverToggle();
                    setState(() {
                      selected = -1;
                    });
                  });
                });
              },
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected==1?Colors.blue:Colors.blue.withOpacity(0.5),
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
                widget.hoverToggle();
                setState(() {
                  selected = 0;
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      body: const Center(child: Text("Properties"))
                  ).show().then((value) {
                    widget.hoverToggle();
                    setState(() {
                      selected = -1;
                    });
                  });
                });
              },
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selected==2?Colors.blue:Colors.blue.withOpacity(0.4),
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

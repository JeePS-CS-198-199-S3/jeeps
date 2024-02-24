import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../../style/constants.dart';

class RouteManagerOptions extends StatefulWidget {
  const RouteManagerOptions({super.key});

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
          Expanded(
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  selected = 0;
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      body: Center(child: Text("Properties"))
                  ).show().then((value) {
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
                  child: Column(
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
          Expanded(
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  selected = 1;
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      body: Center(child: Text("Coordinates"))
                  ).show().then((value) {
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
                  child: Column(
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
          Expanded(
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  selected = 2;
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      body: Center(child: Text("Vehicles"))
                  ).show().then((value) {
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
                  child: Column(
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

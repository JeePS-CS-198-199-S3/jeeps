import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transitrack_web/components/sidemenu.dart';

import '../models/route_model.dart';

class RouteListWidget extends StatefulWidget {
  final List<RouteData> routes;
  const RouteListWidget({Key? key, required this.routes}) : super(key: key);

  @override
  State<RouteListWidget> createState() => _RouteListWidgetState();
}

class _RouteListWidgetState extends State<RouteListWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: ListView.builder(
        itemCount: widget.routes.length,
        itemBuilder: (context, index) {
          return DrawerListTile(Route: widget.routes[index]);
        },
      )
    );
  }
}
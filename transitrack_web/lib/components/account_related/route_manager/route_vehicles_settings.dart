import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../models/jeep_model.dart';
import '../../../models/route_model.dart';

class VehiclesSettings extends StatefulWidget {
  final RouteData? route;
  final List<JeepData>? jeeps;

  const VehiclesSettings({super.key, required this.route, required this.jeeps});

  @override
  State<VehiclesSettings> createState() => _VehiclesSettingsState();
}

class _VehiclesSettingsState extends State<VehiclesSettings> {

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

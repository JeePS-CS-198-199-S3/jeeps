import 'dart:ui';
import 'package:mapbox_gl/mapbox_gl.dart';

class JeepRoute {
  String routeName;
  List<int> routeTime;
  int routeId;
  double routeFareDiscounted;
  double routeFare;
  List<LatLng> routeCoordinates;
  Color routeColor;
  bool enabled;

  JeepRoute({
    required this.routeName,
    required this.routeTime,
    required this.routeId,
    required this.routeFareDiscounted,
    required this.routeFare,
    required this.routeCoordinates,
    required this.routeColor,
    required this.enabled
  });
}

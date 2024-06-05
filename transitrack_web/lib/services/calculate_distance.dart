import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:math';

// Distance calculation to find the nearest point from the device to the route coordinates

double calculateDistance(LatLng point1, LatLng point2) {
  double lat1 = point1.latitude;
  double lon1 = point1.longitude;
  double lat2 = point2.latitude;
  double lon2 = point2.longitude;

  double x = (lat1 - lat2) * (lat1 - lat2);
  double y = (lon1 - lon2) * (lon1 - lon2);

  return sqrt(x + y);
}

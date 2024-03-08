import 'package:mapbox_gl/mapbox_gl.dart';

bool isClockwise(List<LatLng> points) {
  double sum = 0;
  for (int i = 0; i < points.length; i++) {
    LatLng point1 = points[i];
    LatLng point2 = points[(i + 1) % points.length];
    sum += (point2.longitude - point1.longitude) * (point2.latitude + point1.latitude);
  }
  return sum > 0;
}
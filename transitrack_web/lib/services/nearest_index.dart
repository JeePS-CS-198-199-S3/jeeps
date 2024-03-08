import 'package:mapbox_gl/mapbox_gl.dart';

import '../services/calculate_distance.dart';

int findNearestLatLngIndex(LatLng targetPoint, List<LatLng> latLngList) {
  double minDistance = double.infinity;
  int nearestIndex = -1;

  for (int i = 0; i < latLngList.length; i++) {
    double distance = calculateDistance(targetPoint, latLngList[i]);
    if (distance < minDistance) {
      minDistance = distance;
      nearestIndex = i;
    }
  }

  return nearestIndex;
}
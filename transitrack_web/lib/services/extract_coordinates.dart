import 'package:mapbox_gl/mapbox_gl.dart';

List<LatLng> extractCoordinates(dynamic jsonData) {
  List<LatLng> coordinates = [];

  List<dynamic> routes = jsonData['routes'];

  for (var route in routes) {
    List<dynamic> routeCoordinates = route['geometry']['coordinates'];
    for (var coord in routeCoordinates) {
      double latitude = coord[1];
      double longitude = coord[0];
      coordinates.add(LatLng(latitude, longitude));
    }
  }

  return coordinates;
}

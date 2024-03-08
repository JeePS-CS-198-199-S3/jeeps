import 'package:mapbox_gl/mapbox_gl.dart';
import '../../services/is_clockwise.dart';
import '../../services/nearest_index.dart';
import '../../config/keys.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/format_seconds.dart';

Future<String?> eta(List<LatLng> coords, bool is_clockwise, LatLng commuter, LatLng jeep) async {
  // Downsample List if longer than 22 entries
  List<LatLng> downsample = [];
  if (coords.length > 22) {
    double step = coords.length / 22;
    for (int i = 0; i < 22; i++) {
      int index = (i * step).round();
      downsample.add(coords[index]);
    }
  }

  List<LatLng> correctOrientation = downsample;
  List<LatLng> reduced = [];
  if (is_clockwise) {
    if (!isClockwise(coords)) {
      correctOrientation = coords.reversed.toList();
    }

    // Find the nearest points in the route for the start and end
    int index_commuter = findNearestLatLngIndex(commuter, correctOrientation);
    int index_jeep = findNearestLatLngIndex(jeep, correctOrientation);

    if (index_commuter < index_jeep) {
      reduced.addAll(correctOrientation.sublist(index_jeep));
      reduced.addAll(correctOrientation.sublist(0, index_commuter + 1));
    } else {
      reduced = correctOrientation.sublist(index_jeep, index_commuter + 1);
    }
  } else {
    if (isClockwise(coords)) {
      correctOrientation = coords.reversed.toList();
    }
    // Find the nearest points in the route for the start and end
    int index_commuter = findNearestLatLngIndex(commuter, correctOrientation);
    int index_jeep = findNearestLatLngIndex(jeep, correctOrientation);

    if (index_commuter < index_jeep) {
      reduced.addAll(correctOrientation.sublist(index_jeep));
      reduced.addAll(correctOrientation.sublist(0, index_commuter + 1));
    } else {
      reduced = correctOrientation.sublist(index_jeep, index_commuter + 1);
    }
  }
  reduced.add(commuter);
  String query = "";

  for (LatLng point in reduced) {
    query += "${point.longitude},${point.latitude};";
  }

  query = query.substring(0, query.length-1);

  String apiUrl = 'https://api.mapbox.com/directions/v5/mapbox/driving-traffic/$query?geometries=geojson&annotations=speed&access_token=${Keys.MapBoxKey}';



  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    final routes = decoded['routes'] as List<dynamic>;
    return formatSeconds(routes[0]['duration'] as double);
  } else {
    return null;
  }
}
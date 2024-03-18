import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_web/services/extract_coordinates.dart';
import '../../services/is_clockwise.dart';
import '../../services/nearest_index.dart';
import '../../config/keys.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/format_seconds.dart';

Future<EtaData?> eta(List<LatLng> coords, bool is_clockwise, LatLng commuter,
    LatLng jeep) async {
  List<LatLng> correctOrientation = coords;
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

  // Downsample List if longer than 22 entries
  List<LatLng> downsample = [];
  if (reduced.length > 23) {
    double step = reduced.length / 23;
    for (int i = 0; i < 23; i++) {
      int index = (i * step).round();
      downsample.add(reduced[index]);
    }
  } else {
    downsample = reduced;
  }

  downsample.add(commuter);
  reduced.add(commuter);

  String query = "";

  for (LatLng point in downsample) {
    query += "${point.longitude},${point.latitude};";
  }

  query = query.substring(0, query.length - 1);

  String apiUrl =
      'https://api.mapbox.com/directions/v5/mapbox/driving-traffic/$query?geometries=geojson&access_token=${Keys.MapBoxKey}';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    final routes = decoded['routes'] as List<dynamic>;
    return EtaData(
        etaTime: formatSeconds(routes[0]['duration'] as double),
        etaCoordinates: reduced);
  } else {
    return null;
  }
}

class EtaData {
  String etaTime;
  List<LatLng> etaCoordinates;

  EtaData({
    required this.etaTime,
    required this.etaCoordinates,
  });
}

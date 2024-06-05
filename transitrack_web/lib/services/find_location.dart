import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_web/config/keys.dart';

// API Call Function for extracting the coordinate name. This is used in the Reporting Feature since there are
// location sensitive report types like crime, accidents, and mechanical problems

Future<String> findAddress(LatLng latLng) async {
  String loc = '${latLng.longitude},${latLng.latitude}';
  String apiUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$loc.json?access_token=${Keys.MapBoxKey}';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    final features = decoded['features'];
    return '${features[0]['text']}, ${features[2]['text']}';
  } else {
    return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
  }
}

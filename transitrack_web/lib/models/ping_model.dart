import 'package:mapbox_gl/mapbox_gl.dart';

class PingData{
  String ping_email;
  LatLng ping_location;

  PingData({
    required this.ping_email,
    required this.ping_location,
  });
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class PingData {
  String ping_id;
  String ping_email;
  GeoPoint ping_location;
  int ping_route;
  Timestamp ping_timestamp;

  PingData(
      {required this.ping_id,
      required this.ping_email,
      required this.ping_location,
      required this.ping_route,
      required this.ping_timestamp});

  factory PingData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PingData(
      ping_id: doc.id,
      ping_email: data['ping_email'],
      ping_location: data['ping_location'],
      ping_route: data['ping_route'],
      ping_timestamp: data['ping_timestamp'],
    );
  }
}

class PingEntity {
  PingData pingData;
  Circle pingCircle;

  PingEntity({required this.pingData, required this.pingCircle});
}

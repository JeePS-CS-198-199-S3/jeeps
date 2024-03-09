import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class JeepData{
  String device_id;
  Timestamp timestamp;
  int passenger_count;
  int max_capacity;
  GeoPoint location;
  bool is_active;
  int route_id;

  JeepData({
    required this.device_id,
    required this.timestamp,
    required this.passenger_count,
    required this.max_capacity,
    required this.location,
    required this.is_active,
    required this.route_id,
  });

  factory JeepData.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    String device_id = data['device_id'];
    Timestamp timestamp  = data['timestamp'];
    int passenger_count = data['passenger_count'];
    int max_capacity = data['max_capacity'];
    GeoPoint location = data['location'];
    bool is_active = data['is_active'] as bool;
    int route_id = data['route_id'];

    return JeepData(
      device_id: device_id,
      timestamp: timestamp,
      passenger_count: passenger_count,
      max_capacity: max_capacity,
      location: location,
      is_active: is_active,
      route_id: route_id,
    );
  }
}

class JeepEntity{
  JeepData jeep;
  Circle jeepCircle;

  JeepEntity({
   required this.jeep,
   required this.jeepCircle,
  });
}
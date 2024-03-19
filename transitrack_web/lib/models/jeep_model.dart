import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '../models/account_model.dart';

class JeepData {
  String device_id;
  Timestamp timestamp;
  int passenger_count;
  int max_capacity;
  GeoPoint location;
  int route_id;
  double bearing;

  JeepData(
      {required this.device_id,
      required this.timestamp,
      required this.passenger_count,
      required this.max_capacity,
      required this.location,
      required this.route_id,
      required this.bearing});

  factory JeepData.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    String device_id = data['device_id'];
    Timestamp timestamp = data['timestamp'];
    int passenger_count = data['passenger_count'];
    int max_capacity = data['max_capacity'];
    GeoPoint location = data['location'];
    int route_id = data['route_id'];
    double bearing = data['bearing'];

    return JeepData(
        device_id: device_id,
        timestamp: timestamp,
        passenger_count: passenger_count,
        max_capacity: max_capacity,
        location: location,
        route_id: route_id,
        bearing: bearing);
  }
}

class JeepEntity {
  JeepsAndDrivers jeepAndDriver;
  Symbol jeepSymbol;

  JeepEntity({
    required this.jeepAndDriver,
    required this.jeepSymbol,
  });
}

class JeepsAndDrivers {
  AccountData? driver;
  JeepData jeep;

  JeepsAndDrivers({this.driver, required this.jeep});
}

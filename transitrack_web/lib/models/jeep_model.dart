import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool? is_operating;

  JeepData(
      {required this.device_id,
      required this.timestamp,
      required this.passenger_count,
      required this.max_capacity,
      required this.location,
      required this.route_id,
      required this.bearing,
      this.is_operating});

  factory JeepData.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    String device_id = data['device_id'];
    Timestamp timestamp = data['timestamp'];
    int passenger_count = data['passenger_count'];
    int max_capacity = data['max_capacity'];
    GeoPoint location = data['location'];
    int route_id = data['route_id'];
    double bearing = data['bearing'];
    bool? is_operating = data['is_operating'];

    return JeepData(
        device_id: device_id,
        timestamp: timestamp,
        passenger_count: passenger_count,
        max_capacity: max_capacity,
        location: location,
        route_id: route_id,
        bearing: bearing,
        is_operating: is_operating);
  }

  Map<String, dynamic> toGeoJSONFeature() {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [location.longitude, location.latitude]
      },
    };
  }
}

jeepListToGeoJSON(List<JeepData> jeeps) {
  List<Map<String, dynamic>> features =
      jeeps.map((jeep) => jeep.toGeoJSONFeature()).toList();

  Map<String, dynamic> featureCollection = {
    'type': 'FeatureCollection',
    'features': features,
  };

  return featureCollection;
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

class JeepHistoricalData {
  String jeepPlateNumber;
  List<JeepData> data;

  JeepHistoricalData({required this.jeepPlateNumber, required this.data});
}

Future<List<JeepHistoricalData>?> getJeepHistoricalData(
    int routeId, DateTime day) async {
  // Reference to the Firestore collection
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('jeeps_historical');

  DateTime start = day.subtract(const Duration(hours: 1));
  DateTime end = day;

  // Query all documents in the collection
  QuerySnapshot querySnapshot = await collectionReference
      .where('route_id', isEqualTo: routeId)
      .where('timestamp', isGreaterThanOrEqualTo: start)
      .where('timestamp', isLessThan: end)
      .orderBy('timestamp', descending: true)
      .get();

  // Initialize a Set to store unique device IDs
  Set<String> uniqueDeviceIds = Set();

  List<JeepData> entireJeepHistoricalData =
      querySnapshot.docs.map((e) => JeepData.fromSnapshot(e)).toList();

  uniqueDeviceIds = entireJeepHistoricalData.map((e) => e.device_id).toSet();
  List<JeepHistoricalData> jeepHistoricalData =
      uniqueDeviceIds.map((plateNumber) {
    List<JeepData> historicalJeepDataForSpecificJeep = entireJeepHistoricalData
        .where((element) => element.device_id == plateNumber)
        .toList();

    return JeepHistoricalData(
        jeepPlateNumber: plateNumber, data: historicalJeepDataForSpecificJeep);
  }).toList();

  return jeepHistoricalData;
}

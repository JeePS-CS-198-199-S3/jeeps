import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ping_model.dart';

Future<int> sendPing(PingData pingData) async {
  try {
    final pingCollection = FirebaseFirestore.instance.collection('pings');
    await pingCollection.add({
      'ping_email': pingData.ping_email,
      'ping_location': GeoPoint(
          pingData.ping_location.latitude, pingData.ping_location.longitude),
      'ping_route': pingData.ping_route,
      'ping_timestamp': FieldValue.serverTimestamp(),
    });
    return 0;
  } catch (e) {
    return -1;
  }
}

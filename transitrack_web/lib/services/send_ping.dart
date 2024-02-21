import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ping_model.dart';

Future<void> sendPing(PingData pingData) async {
  try {
    final pingCollection = FirebaseFirestore.instance.collection('pings');
    await pingCollection.add({
      'ping_email': pingData.ping_email,
      'ping_location': GeoPoint(pingData.ping_location.latitude, pingData.ping_location.longitude),
      'ping_timestamp': FieldValue.serverTimestamp(),
    });
    print('Ping data added successfully');
  } catch (e) {
    print('Error adding ping data: $e');
  }
}
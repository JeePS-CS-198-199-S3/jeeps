import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

// Uploads a ping to database.

Future<int> sendPing(String email, LatLng location, int route) async {
  try {
    final pingCollection = FirebaseFirestore.instance.collection('pings');
    await pingCollection.add({
      'ping_email': email,
      'ping_location': GeoPoint(location.latitude, location.longitude),
      'ping_route': route,
      'ping_timestamp': FieldValue.serverTimestamp(),
    });
    return 0;
  } catch (e) {
    return -1;
  }
}

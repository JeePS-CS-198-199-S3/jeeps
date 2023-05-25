import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/heatmap_model.dart';
import 'models/jeep_model.dart';

class FireStoreDataBase{
  Stream<List<JeepData>> fetchJeepData(int route_id) {
    final Query<Map<String, dynamic>> jeepRef = FirebaseFirestore.instance.collection('jeeps_realtime').where('route_id', isEqualTo: route_id);
    return jeepRef.snapshots().map((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      return querySnapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return JeepData.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<List<JeepData>> getLatestJeepDataPerDeviceIdFuturev2(int routeId, Timestamp timestamp) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('jeeps_historical')
        .get();

    List<JeepData> jeepDataList = [];

    for (QueryDocumentSnapshot jeepDocument in querySnapshot.docs) {
      QuerySnapshot subcollectionSnapshot = await jeepDocument.reference
          .collection('timeline')
          .where('route_id', isEqualTo: routeId)
          .where('timestamp', isLessThanOrEqualTo: timestamp)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (subcollectionSnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot latestDocument = subcollectionSnapshot.docs.first;
        JeepData jeepData = JeepData.fromSnapshot(latestDocument);
        jeepDataList.add(jeepData);
      }
    }

    return jeepDataList;
  }

  Future<List<JeepData>> getLatestJeepDataAnalysisPerDeviceIdFuture(int routeId, Timestamp timestamp) async {
    // Access the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Create a query to retrieve the documents
    Query query = firestore
        .collection('jeeps_historical')
        .where('route_id', isEqualTo: routeId)
        .where('timestamp', isLessThanOrEqualTo: timestamp)
        .orderBy('timestamp', descending: true);

    // Execute the query and retrieve the query snapshot
    QuerySnapshot querySnapshot = await query.get();

    // Create a map to store the latest documents per unique device_id
    Map<String, QueryDocumentSnapshot> latestDocuments = {};

    // Iterate through the query snapshots
    for (QueryDocumentSnapshot snapshot in querySnapshot.docs) {
      String deviceId = snapshot.get('device_id');

      // Check if the device_id is already present in the map
      if (latestDocuments.containsKey(deviceId)) {
        // Compare the timestamp with the existing one in the map
        Timestamp timestamp = snapshot.get('timestamp');
        Timestamp existingTimestamp = latestDocuments[deviceId]?.get('timestamp');

        if (timestamp.compareTo(existingTimestamp) > 0) {
          // Update the document in the map if the current document has a later timestamp
          latestDocuments[deviceId] = snapshot;
        }
      } else {
        // Add the document to the map if the device_id is not present
        latestDocuments[deviceId] = snapshot;
      }
    }

    // Create a list to store the JeepData objects
    List<JeepData> jeepDataList = [];

    // Iterate through the latest documents and convert them to JeepData objects
    latestDocuments.values.forEach((snapshot) {
      JeepData jeepData = JeepData.fromSnapshot(snapshot);
      jeepDataList.add(jeepData);
    });

    return jeepDataList;
  }

  Stream<List<HeatMapData>> fetchHeatMapRide(int route_id, Timestamp start, Timestamp end) {
    final Query<Map<String, dynamic>> heatmapRef = FirebaseFirestore.instance.collection('heatmap_ride').where('route_id', isEqualTo: route_id).where('timestamp', isGreaterThanOrEqualTo: start).where('timestamp', isLessThanOrEqualTo: end);
    return heatmapRef.snapshots().map((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      return querySnapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return HeatMapData.fromSnapshot(doc);
      }).toList();
    });
  }

  Stream<List<HeatMapData>> fetchHeatMapDrop(int route_id, Timestamp start, Timestamp end) {
    final Query<Map<String, dynamic>> heatmapRef = FirebaseFirestore.instance.collection('heatmap_drop').where('route_id', isEqualTo: route_id).where('timestamp', isGreaterThanOrEqualTo: start).where('timestamp', isLessThanOrEqualTo: end);
    return heatmapRef.snapshots().map((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      return querySnapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return HeatMapData.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<List<JeepData>> loadJeepsByRouteId(int routeId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('jeeps_realtime')
        .where('route_id', isEqualTo: routeId)
        .get();

    List<JeepData> jeepDataList = snapshot.docs
        .map((doc) => JeepData.fromSnapshot(doc))
        .toList();

    return jeepDataList;
  }
}


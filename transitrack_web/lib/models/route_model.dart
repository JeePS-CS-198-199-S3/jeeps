import 'package:cloud_firestore/cloud_firestore.dart';

class RouteData {
  bool enabled;
  int routeColor;
  List<GeoPoint> routeCoordinates;
  double routeFare;
  double routeFareDiscounted;
  int routeId;
  String routeName;
  List<int> routeTime;

  RouteData({
    required this.enabled,
    required this.routeColor,
    required this.routeCoordinates,
    required this.routeFare,
    required this.routeFareDiscounted,
    required this.routeId,
    required this.routeName,
    required this.routeTime,
  });

  factory RouteData.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return RouteData(
      enabled: data['enabled'] ?? false,
      routeColor: data['route_color'] ?? 0,
      routeCoordinates: (data['route_coordinates'] as List<dynamic>)
          .map((coord) => coord as GeoPoint)
          .toList(),
      routeFare: data['route_fare'] ?? 0.0,
      routeFareDiscounted: data['route_fare_discounted'] ?? 0.0,
      routeId: data['route_id'] ?? 0,
      routeName: data['route_name'] ?? '',
      routeTime: (data['route_time'] as List<dynamic>)
          .map((time) => time as int)
          .toList(),
    );
  }

  static GeoPoint fromMap(Map<String, dynamic> map) {
    return GeoPoint(
      map['latitude'],
      map['longitude']
    );
  }
}

import 'package:mapbox_gl/mapbox_gl.dart';

etaListToGeoJSON(List<LatLng> routeCoordinates) {
  Map<String, dynamic> featureCollection = {
    'type': 'FeatureCollection',
    'features': [
      {
        'type': 'Feature',
        "id": 0,
        "properties": <String, dynamic>{},
        'geometry': {
          "coordinates":
              routeCoordinates.map((e) => [e.longitude, e.latitude]).toList(),
          "type": "LineString"
        },
      }
    ],
  };
  return featureCollection;
}

Future<void> addETALayer(MapboxMapController mapController) async {
  mapController.addSource("eta",
      GeojsonSourceProperties(data: etaListToGeoJSON([]), cluster: false));
  mapController.addLineLayer(
      "eta",
      "eta-line",
      const LineLayerProperties(
          lineColor: "#FFFFFF",
          lineWidth: 5.0,
          lineOpacity: 0.5,
          lineCap: "round",
          lineJoin: "round",
          lineDasharray: [3, 2]));
}

import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

// Load the necessary map assets

Future<void> addImageFromAsset(MapboxMapController mapController) async {
  final ByteData bytes1 = await rootBundle.load("assets/jeep.png");
  final Uint8List list1 = bytes1.buffer.asUint8List();

  final ByteData bytes2 = await rootBundle.load("assets/jeepSelected.png");
  final Uint8List list2 = bytes2.buffer.asUint8List();

  await mapController.addImage("jeepTop", list1);
  await mapController.addImage("jeepTopSelected", list2);
}

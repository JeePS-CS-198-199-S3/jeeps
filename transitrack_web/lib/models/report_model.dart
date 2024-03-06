import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class ReportData {
  String report_sender;
  String report_recepient;
  String report_jeepney;
  Timestamp timestamp;
  String report_content;
  int report_type;
  LatLng report_location;

  ReportData({
    required this.report_sender,
    required this.report_recepient,
    required this.report_jeepney,
    required this.timestamp,
    required this.report_content,
    required this.report_type,
    required this.report_location
  });

  static Map<String, int> reportTypeMap = {
    'Lost Item': 0,
    'Crime Incident': 1,
    'Mechanical Failure': 2,
    'Accident': 3,
    'Other Concerns': 4,
  };

  static List<String> reportType = [
    'Lost Item',
    'Crime Incident',
    'Mechanical Failure',
    'Accident',
    'Other Concerns',
  ];
}
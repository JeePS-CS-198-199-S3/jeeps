import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackData {
  String feedback_sender;
  String feedback_recepient;
  String feedback_jeepney;
  Timestamp timestamp;
  String feedback_content;
  int feedback_rating;
  int feedback_type; // 0 for both, 1 for driver, 2 for jeepney

  FeedbackData({
    required this.feedback_sender,
    required this.feedback_recepient,
    required this.feedback_jeepney,
    required this.timestamp,
    required this.feedback_content,
    required this.feedback_rating,
    required this.feedback_type,
  });

  static Map<String, int> feedbackTypeMap = {
    'Both': 0,
    'Driver': 1,
    'Jeepney': 2,
  };

  static List<String> feedbackType = [
    'Both',
    'Driver',
    'Jeepney',
  ];
}
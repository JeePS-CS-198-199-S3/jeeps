import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:transitrack_web/components/map_related/map.dart';
import 'package:transitrack_web/models/account_model.dart';

class FeedbackData {
  String feedback_sender;
  String feedback_recepient;
  String feedback_jeepney;
  Timestamp timestamp;
  int feedback_driving_rating;
  int feedback_jeepney_rating;
  int feedback_route;
  String feedback_content;

  FeedbackData(
      {required this.feedback_sender,
      required this.feedback_recepient,
      required this.feedback_jeepney,
      required this.timestamp,
      required this.feedback_route,
      required this.feedback_driving_rating,
      required this.feedback_content,
      required this.feedback_jeepney_rating});

  factory FeedbackData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return FeedbackData(
      feedback_sender: data['feedback_sender'] ?? '',
      feedback_recepient: data['feedback_recepient'] ?? '',
      feedback_jeepney: data['feedback_jeepney'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      feedback_driving_rating: data['feedback_driving_rating'] ?? 0,
      feedback_jeepney_rating: data['feedback_jeepney_rating'] ?? 0,
      feedback_content: data['feedback_content'] ?? '',
      feedback_route: data['feedback_route'] ?? 0,
    );
  }
}

class UsersAdditionalInfo {
  AccountData senderData;
  AccountData recepientData;
  String? locationData;

  UsersAdditionalInfo(
      {required this.senderData,
      required this.recepientData,
      this.locationData});
}

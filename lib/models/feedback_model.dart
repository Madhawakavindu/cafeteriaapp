import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String canteenId;
  final String comment;
  final int rating;
  final DateTime timestamp;

  FeedbackModel({
    required this.id,
    required this.canteenId,
    required this.comment,
    required this.rating,
    required this.timestamp,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String id) {
    return FeedbackModel(
      id: id,
      canteenId: map['canteenId'],
      comment: map['comment'],
      rating: map['rating'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}

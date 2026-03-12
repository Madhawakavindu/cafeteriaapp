import 'package:cafeteria/core/services/firestore_service.dart';

class FeedbackRepository {
  static final FeedbackRepository _instance = FeedbackRepository._internal();
  final FirestoreService _firestoreService = FirestoreService();

  factory FeedbackRepository() => _instance;
  FeedbackRepository._internal();

  Future<void> submitFeedback({
    required String menuItemId,
    required String menuItemName,
    required String canteenId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
    required String date,
  }) async {
    await _firestoreService.createFeedback({
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'canteenId': canteenId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'date': date,
    });
  }

  Future<List<Map<String, dynamic>>> getFeedbackForMenuItem(
    String menuItemId,
  ) async {
    return _firestoreService.getFeedbackForMenuItem(menuItemId);
  }
}

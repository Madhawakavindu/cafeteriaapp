import 'package:cafeteria/models/feedback_model.dart';

class FeedbackService {
  static final List<FeedbackModel> _items = [];

  static Future<void> submitFeedback({
    required String canteenId,
    required String comment,
    required int rating,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final entry = FeedbackModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      canteenId: canteenId,
      comment: comment,
      rating: rating,
      timestamp: DateTime.now(),
    );
    _items.add(entry);
  }

  static Future<List<FeedbackModel>> getFeedbackForCanteen(
    String canteenId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _items.where((f) => f.canteenId == canteenId).toList();
  }
}

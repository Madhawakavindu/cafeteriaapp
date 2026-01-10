import 'package:cafeteria/models/feedback_model.dart';
import 'database_service.dart';

class FeedbackService {
  static final _dbService = DatabaseService();

  static Future<void> submitFeedback({
    required String canteenId,
    required String comment,
    required int rating,
    required String userId,
  }) async {
    final db = await _dbService.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('feedback', {
      'id': id,
      'canteenId': canteenId,
      'userId': userId,
      'comment': comment,
      'rating': rating,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<FeedbackModel>> getFeedbackForCanteen(
    String canteenId,
  ) async {
    final db = await _dbService.database;
    final result = await db.query(
      'feedback',
      where: 'canteenId = ?',
      whereArgs: [canteenId],
    );

    return result
        .map((map) => FeedbackModel.fromMap(map, map['id'] as String))
        .toList();
  }

  static Future<List<FeedbackModel>> getAllFeedback() async {
    final db = await _dbService.database;
    final result = await db.query('feedback');
    return result
        .map((map) => FeedbackModel.fromMap(map, map['id'] as String))
        .toList();
  }
}

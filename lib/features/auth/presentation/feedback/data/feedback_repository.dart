import 'package:cafeteria/core/constants/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> submitFeedback(
    String canteenId,
    String food,
    String comment,
    int rating,
  ) async {
    await _db.collection(FirestoreCollections.feedback).add({
      'canteenId': canteenId,
      'food': food,
      'comment': comment,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getFeedback(String canteenId) {
    return _db
        .collection(FirestoreCollections.feedback)
        .where('canteenId', isEqualTo: canteenId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

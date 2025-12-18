import 'package:cafeteria/core/constants/firestore_collections.dart';
import 'package:cafeteria/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../services/firestore_service.dart';

class MenuRepository {
  final _service = FirestoreService();

  Stream<QuerySnapshot<Map<String, dynamic>>> getTodayMenu(
    String canteenId,
    String date,
  ) {
    return _service.instance
        .collection(FirestoreCollections.menus)
        .doc(canteenId)
        .collection(date)
        .snapshots();
  }

  Stream<DocumentSnapshot> getMeal(
    String canteenId,
    String date,
    String mealType,
    String foodName,
  ) {
    return _service.instance
        .collection(FirestoreCollections.menus)
        .doc(canteenId)
        .collection(date)
        .doc(mealType)
        .collection('foods')
        .doc(foodName)
        .snapshots();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_collections.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _db;

  CollectionReference get users => _db.collection(FirestoreCollections.users);
  CollectionReference get feedback =>
      _db.collection(FirestoreCollections.feedback);
  CollectionReference get orders => _db.collection(FirestoreCollections.orders);
  CollectionReference get ratings =>
      _db.collection(FirestoreCollections.ratings);

  DocumentReference menuDoc(String canteen, String date, String mealType) {
    return _db
        .collection(FirestoreCollections.menus)
        .doc(canteen)
        .collection(date)
        .doc(mealType);
  }
}

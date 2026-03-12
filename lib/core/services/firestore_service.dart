import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  // Collections
  static const String usersCollection = 'users';
  static const String canteensCollection = 'canteens';
  static const String menuItemsCollection = 'menuItems';
  static const String ordersCollection = 'orders';

  // User Operations
  Future<void> createUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Canteen Operations
  Future<void> createCanteen(
    String canteenId,
    Map<String, dynamic> canteenData,
  ) async {
    try {
      await _firestore.collection(canteensCollection).doc(canteenId).set({
        ...canteenData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create canteen: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCanteens() async {
    try {
      final snapshot = await _firestore
          .collection(canteensCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('Failed to fetch canteens: $e');
    }
  }

  Future<Map<String, dynamic>?> getCanteen(String canteenId) async {
    try {
      final doc = await _firestore
          .collection(canteensCollection)
          .doc(canteenId)
          .get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch canteen: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOwnerCanteens(String ownerId) async {
    try {
      final snapshot = await _firestore
          .collection(canteensCollection)
          .where('owner', isEqualTo: ownerId)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('Failed to fetch owner canteens: $e');
    }
  }

  Future<void> updateCanteen(
    String canteenId,
    Map<String, dynamic> canteenData,
  ) async {
    try {
      await _firestore.collection(canteensCollection).doc(canteenId).update({
        ...canteenData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update canteen: $e');
    }
  }

  Future<void> deleteCanteen(String canteenId) async {
    try {
      await _firestore.collection(canteensCollection).doc(canteenId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete canteen: $e');
    }
  }

  // Menu Item Operations
  Future<void> createMenuItem(
    String menuItemId,
    Map<String, dynamic> itemData,
  ) async {
    try {
      await _firestore.collection(menuItemsCollection).doc(menuItemId).set({
        ...itemData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create menu item: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMenuByCanteen(
    String canteenId, {
    String? category,
  }) async {
    try {
      Query query = _firestore
          .collection(menuItemsCollection)
          .where('canteen', isEqualTo: canteenId)
          .where('isAvailable', isEqualTo: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.orderBy('category').orderBy('name').get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch menu: $e');
    }
  }

  Future<Map<String, dynamic>?> getMenuItem(String menuItemId) async {
    try {
      final doc = await _firestore
          .collection(menuItemsCollection)
          .doc(menuItemId)
          .get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch menu item: $e');
    }
  }

  Future<void> updateMenuItem(
    String menuItemId,
    Map<String, dynamic> itemData,
  ) async {
    try {
      await _firestore.collection(menuItemsCollection).doc(menuItemId).update({
        ...itemData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update menu item: $e');
    }
  }

  Future<void> deleteMenuItem(String menuItemId) async {
    try {
      await _firestore.collection(menuItemsCollection).doc(menuItemId).update({
        'isAvailable': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete menu item: $e');
    }
  }

  // Order Operations
  Future<void> createOrder(
    String orderId,
    Map<String, dynamic> orderData,
  ) async {
    try {
      await _firestore.collection(ordersCollection).doc(orderId).set({
        ...orderData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final doc = await _firestore
          .collection(ordersCollection)
          .doc(orderId)
          .get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(ordersCollection)
          .where('user', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCanteenOrders(String canteenId) async {
    try {
      final snapshot = await _firestore
          .collection(ordersCollection)
          .where('canteen', isEqualTo: canteenId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('Failed to fetch canteen orders: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (status == 'completed') {
        updateData['deliveryTime'] = FieldValue.serverTimestamp();
      }
      await _firestore
          .collection(ordersCollection)
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> updateOrderPaymentStatus(
    String orderId,
    String paymentStatus,
  ) async {
    try {
      await _firestore.collection(ordersCollection).doc(orderId).update({
        'paymentStatus': paymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Watch for real-time updates
  Stream<List<Map<String, dynamic>>> watchCanteens() {
    return _firestore
        .collection(canteensCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<Map<String, dynamic>?> watchCanteen(String canteenId) {
    return _firestore
        .collection(canteensCollection)
        .doc(canteenId)
        .snapshots()
        .map((doc) => doc.exists ? {'id': doc.id, ...doc.data()!} : null);
  }

  Stream<List<Map<String, dynamic>>> watchMenuByCanteen(String canteenId) {
    return _firestore
        .collection(menuItemsCollection)
        .where('canteen', isEqualTo: canteenId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> watchUserOrders(String userId) {
    return _firestore
        .collection(ordersCollection)
        .where('user', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> watchCanteenOrders(String canteenId) {
    return _firestore
        .collection(ordersCollection)
        .where('canteen', isEqualTo: canteenId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }
}

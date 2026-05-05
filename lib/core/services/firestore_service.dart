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
  static const String ownerRequestsCollection = 'ownerRequests';

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

  Future<void> createOwnerRequest(Map<String, dynamic> data) async {
    try {
      await _firestore.collection(ownerRequestsCollection).add({
        ...data,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create owner request: $e');
    }
  }

  Future<bool> hasPendingOwnerRequest(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(ownerRequestsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.any(
        (doc) => (doc.data()['status'] ?? '').toString() == 'pending',
      );
    } catch (e) {
      throw Exception('Failed to check owner request status: $e');
    }
  }

  Future<Map<String, dynamic>?> getLatestOwnerRequest(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(ownerRequestsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final docs = [...snapshot.docs]
        ..sort((a, b) {
          final ta = a.data()['createdAt'];
          final tb = b.data()['createdAt'];
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return (tb as Timestamp).compareTo(ta as Timestamp);
        });

      final doc = docs.first;
      return {'id': doc.id, ...doc.data()};
    } catch (e) {
      throw Exception('Failed to fetch latest owner request: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> watchPendingOwnerRequests() {
    return _firestore
        .collection(ownerRequestsCollection)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();

          items.sort((a, b) {
            final ta = a['createdAt'];
            final tb = b['createdAt'];
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return (ta as Timestamp).compareTo(tb as Timestamp);
          });

          return items;
        });
  }

  Future<void> reviewOwnerRequest({
    required String requestId,
    required String userId,
    required String canteenId,
    required String canteenName,
    required String reviewerId,
    required bool approve,
  }) async {
    try {
      final requestRef = _firestore
          .collection(ownerRequestsCollection)
          .doc(requestId);
      final userRef = _firestore.collection(usersCollection).doc(userId);

      await _firestore.runTransaction((transaction) async {
        final requestSnapshot = await transaction.get(requestRef);
        if (!requestSnapshot.exists) {
          throw Exception('Owner request no longer exists.');
        }

        final requestData = requestSnapshot.data();
        if (requestData == null || requestData['status'] != 'pending') {
          throw Exception('This request has already been reviewed.');
        }

        transaction.update(requestRef, {
          'status': approve ? 'approved' : 'rejected',
          'reviewedBy': reviewerId,
          'reviewedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (approve) {
          transaction.update(userRef, {
            'role': 'owner',
            'canteenId': canteenId,
            'canteenName': canteenName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to review owner request: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> watchOwners() {
    return _firestore
        .collection(usersCollection)
        .where('role', isEqualTo: 'owner')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> revokeOwnerRole(String userId) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'role': 'user',
        'canteenId': null,
        'canteenName': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove owner access: $e');
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

      final snapshot = await query.get();

      final results = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Sort in memory to avoid needing a Firestore composite index
      results.sort((a, b) {
        final catA = (a['category'] ?? '').toString();
        final catB = (b['category'] ?? '').toString();
        final cmp = catA.compareTo(catB);
        if (cmp != 0) return cmp;
        return (a['name'] ?? '').toString().compareTo(
          (b['name'] ?? '').toString(),
        );
      });

      return results;
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
          .get();

      final results = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .where(
            (order) =>
                (order['hiddenForUser'] as bool?) != true &&
                (order['status']?.toString() ?? '') != 'received',
          )
          .toList();

      // Sort newest first in memory to avoid requiring a composite index.
      results.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta is Timestamp && tb is Timestamp) {
          return tb.compareTo(ta);
        }
        return 0;
      });

      return results;
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

  Future<void> markOrderReceivedByUser(String orderId) async {
    try {
      await _firestore.collection(ordersCollection).doc(orderId).update({
        'status': 'received',
        'receivedByUser': true,
        'hiddenForUser': true,
        'receivedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark order as received: $e');
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
        .snapshots()
        .map((snapshot) {
          final results = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .where(
                (order) =>
                    (order['hiddenForUser'] as bool?) != true &&
                    (order['status']?.toString() ?? '') != 'received',
              )
              .toList();

          // Sort newest first in memory to avoid requiring a composite index.
          results.sort((a, b) {
            final ta = a['createdAt'];
            final tb = b['createdAt'];
            if (ta is Timestamp && tb is Timestamp) {
              return tb.compareTo(ta);
            }
            return 0;
          });

          return results;
        });
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

  // ── Feedback Operations ─────────────────────────────────────────────────────
  static const String feedbackCollection = 'feedback';

  Future<void> createFeedback(Map<String, dynamic> data) async {
    try {
      await _firestore.collection(feedbackCollection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFeedbackForMenuItem(
    String menuItemId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(feedbackCollection)
          .where('menuItemId', isEqualTo: menuItemId)
          .get();
      final results = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      // Sort newest first in memory to avoid index requirement
      results.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta == null || tb == null) return 0;
        return (tb as Timestamp).compareTo(ta as Timestamp);
      });
      return results;
    } catch (e) {
      throw Exception('Failed to fetch feedback: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> watchFeedbackForCanteen(String canteenId) {
    return _firestore
        .collection(feedbackCollection)
        .where('canteenId', isEqualTo: canteenId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }
}

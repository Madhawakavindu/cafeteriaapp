import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'firestore_service.dart';

class OwnerRequestService {
  final FirestoreService _firestoreService = FirestoreService();
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  Future<void> submitOwnerRequest({
    required String canteenId,
    required String canteenName,
    String? note,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Please login first.');
    }

    final userData = await _firestoreService.getUser(user.uid);
    if (userData == null) {
      throw Exception('User profile not found.');
    }

    if ((userData['role'] ?? 'user') == 'owner') {
      throw Exception('You are already an owner.');
    }

    final hasPending = await _firestoreService.hasPendingOwnerRequest(user.uid);
    if (hasPending) {
      throw Exception('You already have a pending owner request.');
    }

    await _firestoreService.createOwnerRequest({
      'userId': user.uid,
      'userEmail': user.email ?? userData['email'] ?? '',
      'userName': userData['name'] ?? '',
      'canteenId': canteenId,
      'canteenName': canteenName,
      'note': note?.trim() ?? '',
    });
  }

  Future<Map<String, dynamic>?> getLatestMyRequest() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Please login first.');
    }

    return _firestoreService.getLatestOwnerRequest(user.uid);
  }

  Stream<List<Map<String, dynamic>>> watchPendingRequests() {
    return _firestoreService.watchPendingOwnerRequests();
  }

  Stream<List<Map<String, dynamic>>> watchCurrentOwners() {
    return _firestoreService.watchOwners();
  }

  Future<void> approveRequest({
    required String requestId,
    required String userId,
    required String canteenId,
    required String canteenName,
  }) async {
    final reviewer = _firebaseAuth.currentUser;
    if (reviewer == null) {
      throw Exception('Please login as admin.');
    }

    await _firestoreService.reviewOwnerRequest(
      requestId: requestId,
      userId: userId,
      canteenId: canteenId,
      canteenName: canteenName,
      reviewerId: reviewer.uid,
      approve: true,
    );
  }

  Future<void> rejectRequest({
    required String requestId,
    required String userId,
    required String canteenId,
    required String canteenName,
  }) async {
    final reviewer = _firebaseAuth.currentUser;
    if (reviewer == null) {
      throw Exception('Please login as admin.');
    }

    await _firestoreService.reviewOwnerRequest(
      requestId: requestId,
      userId: userId,
      canteenId: canteenId,
      canteenName: canteenName,
      reviewerId: reviewer.uid,
      approve: false,
    );
  }

  Future<void> removeOwnerAccess(String userId) async {
    final reviewer = _firebaseAuth.currentUser;
    if (reviewer == null) {
      throw Exception('Please login as admin.');
    }

    await _firestoreService.revokeOwnerRole(userId);
  }
}

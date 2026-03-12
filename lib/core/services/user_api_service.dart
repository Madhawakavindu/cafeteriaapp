import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'firestore_service.dart';

class UserApiService {
  final FirestoreService _firestoreService = FirestoreService();
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      final userData = await _firestoreService.getUser(currentUser.uid);
      if (userData == null) {
        return null;
      }

      return {'id': currentUser.uid, ...userData};
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      await _firestoreService.updateUser(currentUser.uid, data);
      final updated = await _firestoreService.getUser(currentUser.uid);
      return {'id': currentUser.uid, ...(updated ?? <String, dynamic>{})};
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw Exception('No authenticated user');
      }

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreService.usersCollection)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }
}

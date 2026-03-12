import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cafeteria/core/services/firestore_service.dart';
import '../models/user.dart' as user_model;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  user_model.User? _currentUser;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  user_model.User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  bool get isOwner => _currentUser?.role == 'owner';

  Future<void> register(
    String email,
    String password,
    String name, {
    String role = 'user',
    String? canteenId,
  }) async {
    try {
      // Create Firebase user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Store user data in Firestore
      await _firestoreService.createUser(userId, {
        'email': email,
        'name': name,
        'role': role,
        'canteenId': role == 'owner' ? canteenId : null,
        'isActive': true,
      });

      // Set current user
      _currentUser = user_model.User(
        id: userId,
        email: email,
        name: name,
        role: role,
        canteenId: role == 'owner' ? canteenId : null,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      _currentUser = null;
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      _currentUser = null;
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // Authenticate with Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Fetch user data from Firestore
      final userData = await _firestoreService.getUser(userId);

      if (userData != null) {
        _currentUser = user_model.User(
          id: userId,
          email: userData['email'] ?? email,
          name: userData['name'] ?? '',
          role: userData['role'] ?? 'user',
          canteenId: userData['canteenId'],
          canteenName: userData['canteenName'],
        );
      } else {
        throw Exception('User data not found in Firestore');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _currentUser = null;
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      _currentUser = null;
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        _currentUser = null;
        return;
      }

      // Fetch user data from Firestore
      final userData = await _firestoreService.getUser(firebaseUser.uid);

      if (userData != null) {
        _currentUser = user_model.User(
          id: firebaseUser.uid,
          email: userData['email'] ?? firebaseUser.email ?? '',
          name: userData['name'] ?? '',
          role: userData['role'] ?? 'user',
          canteenId: userData['canteenId'],
          canteenName: userData['canteenName'],
        );
      }
    } catch (e) {
      _currentUser = null;
      throw Exception('Failed to load user: $e');
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Password change failed: ${e.message}');
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Stream<user_model.User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        return null;
      }

      try {
        final userData = await _firestoreService.getUser(firebaseUser.uid);
        if (userData != null) {
          _currentUser = user_model.User(
            id: firebaseUser.uid,
            email: userData['email'] ?? firebaseUser.email ?? '',
            name: userData['name'] ?? '',
            role: userData['role'] ?? 'user',
            canteenId: userData['canteenId'],
            canteenName: userData['canteenName'],
          );
          return _currentUser;
        }
      } catch (e) {
        print('Error loading user: $e');
      }
      return null;
    });
  }
}

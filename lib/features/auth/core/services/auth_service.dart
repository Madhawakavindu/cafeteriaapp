import 'package:cafeteria/features/auth/core/models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  User? _currentUser;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  bool get isOwner => _currentUser?.role == 'owner';

  Future<void> login(String email, String password) async {
    // Simulate authentication
    await Future.delayed(const Duration(milliseconds: 500));

    // Demo owners and users
    if (email == 'owner@cafeteria.com' && password == 'owner123') {
      _currentUser = User(
        id: 'owner_1',
        email: email,
        name: 'Canteen Owner',
        role: 'owner',
        canteenId: 'canteen_1',
        canteenName: 'Main Cafeteria',
      );
    } else if (email == 'owner2@cafeteria.com' && password == 'owner123') {
      _currentUser = User(
        id: 'owner_2',
        email: email,
        name: 'Second Owner',
        role: 'owner',
        canteenId: 'canteen_2',
        canteenName: 'Secondary Cafeteria',
      );
    } else if (email.contains('@')) {
      // Regular user
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@')[0],
        role: 'user',
      );
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}

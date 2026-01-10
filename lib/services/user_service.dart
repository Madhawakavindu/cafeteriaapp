import 'package:cafeteria/models/user_model.dart';

class UserService {
  static UserModel? _currentUser;

  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Admin credentials
    if (email == 'admin@cafeteria.com' && password == 'admin123') {
      _currentUser = UserModel(
        uid: 'admin1',
        email: 'admin@cafeteria.com',
        role: 'admin',
        selectedCanteen: null,
      );
      return _currentUser!;
    }

    // Student credentials
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = UserModel(
        uid: 'student${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        role: 'student',
        selectedCanteen: null,
      );
      return _currentUser!;
    }

    throw Exception('Invalid credentials');
  }

  static Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    return _currentUser!;
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  static bool isLoggedIn() {
    return _currentUser != null;
  }

  static bool isAdmin() {
    return _currentUser?.role == 'admin';
  }
}

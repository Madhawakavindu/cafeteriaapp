import 'package:cafeteria/models/user_model.dart';

class UserService {
  static final UserModel _currentUser = UserModel(
    uid: 'u1',
    email: 'student@example.com',
    role: 'student',
    selectedCanteen: null,
  );

  static Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }
}

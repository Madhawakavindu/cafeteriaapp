class UserModel {
  final String uid;
  final String email;
  final String role; // "student" or "admin"
  final String? selectedCanteen;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.selectedCanteen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      selectedCanteen: map['selectedCanteen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'role': role, 'selectedCanteen': selectedCanteen};
  }
}

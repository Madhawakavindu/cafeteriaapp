class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'owner' or 'user'
  final String? canteenId; // Only for owners
  final String? canteenName; // Only for owners

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.canteenId,
    this.canteenName,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? canteenId,
    String? canteenName,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      canteenId: canteenId ?? this.canteenId,
      canteenName: canteenName ?? this.canteenName,
    );
  }
}

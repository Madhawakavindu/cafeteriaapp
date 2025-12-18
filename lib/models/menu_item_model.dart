class MenuItemModel {
  final String name;
  final String description;
  final List<String> vegetables;

  MenuItemModel({
    required this.name,
    required this.description,
    required this.vegetables,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      vegetables: List<String>.from(map['vegetables'] ?? []),
    );
  }
}

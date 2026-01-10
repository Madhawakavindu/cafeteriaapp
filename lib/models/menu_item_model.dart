class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final List<String> vegetables;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int quantity;
  final String mealType; // "breakfast", "lunch", "dinner"

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.vegetables,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    required this.quantity,
    required this.mealType,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      vegetables: List<String>.from(map['vegetables'] ?? []),
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      isAvailable: map['isAvailable'] ?? true,
      quantity: map['quantity'] ?? 0,
      mealType: map['mealType'] ?? 'lunch',
    );
  }
}

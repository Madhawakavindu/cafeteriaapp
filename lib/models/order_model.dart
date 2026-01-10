class OrderModel {
  final String id;
  final String canteenId;
  final String mealType;
  final String mainFood;
  final List<String> vegetables;
  final String status;

  OrderModel({
    required this.id,
    required this.canteenId,
    required this.mealType,
    required this.mainFood,
    required this.vegetables,
    required this.status,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      canteenId: map['canteenId'] ?? '',
      mealType: map['mealType'] ?? '',
      mainFood: map['mainFood'] ?? '',
      vegetables: (map['vegetables'] as String?)?.split(',') ?? [],
      status: map['status'] ?? 'Pending',
    );
  }
}

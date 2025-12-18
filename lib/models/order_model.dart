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
}

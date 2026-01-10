import 'package:cafeteria/models/order_model.dart';

class OrderService {
  static final List<OrderModel> _orders = [
    OrderModel(
      id: 'o1',
      canteenId: 'Canteen1',
      mealType: 'lunch',
      mainFood: 'Biryani',
      vegetables: ['Onion', 'Tomato'],
      status: 'Completed',
    ),
    OrderModel(
      id: 'o2',
      canteenId: 'Canteen2',
      mealType: 'breakfast',
      mainFood: 'Dosa',
      vegetables: ['Potato'],
      status: 'Preparing',
    ),
  ];

  static Future<List<OrderModel>> getMyOrders() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _orders;
  }
}

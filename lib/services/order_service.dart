import 'package:cafeteria/models/order_model.dart';
import 'database_service.dart';

class OrderService {
  static final _dbService = DatabaseService();

  static Future<void> createOrder({
    required String canteenId,
    required String mealType,
    required String mainFood,
    required List<String> vegetables,
    required String userId,
  }) async {
    final db = await _dbService.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('orders', {
      'id': id,
      'canteenId': canteenId,
      'userId': userId,
      'mealType': mealType,
      'mainFood': mainFood,
      'vegetables': vegetables.join(','),
      'status': 'Pending',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<OrderModel>> getMyOrders(String userId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return result.map((map) => OrderModel.fromMap(map)).toList();
  }

  static Future<List<OrderModel>> getAllOrders() async {
    final db = await _dbService.database;
    final result = await db.query('orders');
    return result.map((map) => OrderModel.fromMap(map)).toList();
  }

  static Future<List<OrderModel>> getOrdersByCanteen(String canteenId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'orders',
      where: 'canteenId = ?',
      whereArgs: [canteenId],
    );

    return result.map((map) => OrderModel.fromMap(map)).toList();
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    final db = await _dbService.database;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }
}

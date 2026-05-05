import 'package:uuid/uuid.dart';
import 'firestore_service.dart';

class OrderApiService {
  final FirestoreService _firestoreService = FirestoreService();
  static const uuid = Uuid();

  Future<Map<String, dynamic>> createOrder(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final orderId = uuid.v4();
      final orderNumber =
          'ORD-${DateTime.now().millisecondsSinceEpoch}-${(9999 * 0.8).toInt()}';

      final orderData = {
        ...data,
        'user': userId,
        'orderNumber': orderNumber,
        'status': 'pending',
        'paymentStatus': 'pending',
      };

      await _firestoreService.createOrder(orderId, orderData);

      return {'id': orderId, ...orderData};
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<Map<String, dynamic>?> getOrderById(String id) async {
    try {
      return await _firestoreService.getOrder(id);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      return await _firestoreService.getUserOrders(userId);
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCanteenOrders(String canteenId) async {
    try {
      return await _firestoreService.getCanteenOrders(canteenId);
    } catch (e) {
      throw Exception('Failed to fetch canteen orders: $e');
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _firestoreService.updateOrderStatus(id, status);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> updatePaymentStatus(String id, String paymentStatus) async {
    try {
      await _firestoreService.updateOrderPaymentStatus(id, paymentStatus);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  Future<void> markOrderReceived(String orderId) async {
    try {
      await _firestoreService.markOrderReceivedByUser(orderId);
    } catch (e) {
      throw Exception('Failed to mark order as received: $e');
    }
  }
}

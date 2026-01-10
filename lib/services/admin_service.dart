import 'package:cafeteria/models/feedback_model.dart';
import 'package:cafeteria/models/order_model.dart';
import 'feedback_service.dart';
import 'order_service.dart';

class AdminService {
  // Get all feedback from all canteens
  static Future<List<FeedbackModel>> getAllFeedback() async {
    return await FeedbackService.getAllFeedback();
  }

  // Get all orders from all canteens
  static Future<List<OrderModel>> getAllOrders() async {
    return await OrderService.getAllOrders();
  }

  // Get feedback statistics
  static Future<Map<String, dynamic>> getFeedbackStats() async {
    final allFeedback = await getAllFeedback();

    if (allFeedback.isEmpty) {
      return {
        'totalFeedback': 0,
        'averageRating': 0.0,
        'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }

    final totalRating = allFeedback.fold<int>(0, (sum, f) => sum + f.rating);
    final averageRating = totalRating / allFeedback.length;

    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var feedback in allFeedback) {
      distribution[feedback.rating] = (distribution[feedback.rating] ?? 0) + 1;
    }

    return {
      'totalFeedback': allFeedback.length,
      'averageRating': double.parse(averageRating.toStringAsFixed(2)),
      'ratingDistribution': distribution,
    };
  }

  // Get order statistics
  static Future<Map<String, dynamic>> getOrderStats() async {
    final allOrders = await getAllOrders();

    if (allOrders.isEmpty) {
      return {
        'totalOrders': 0,
        'statusDistribution': {},
        'mealTypeDistribution': {},
      };
    }

    final statusDist = <String, int>{};
    final mealTypeDist = <String, int>{};

    for (var order in allOrders) {
      statusDist[order.status] = (statusDist[order.status] ?? 0) + 1;
      mealTypeDist[order.mealType] = (mealTypeDist[order.mealType] ?? 0) + 1;
    }

    return {
      'totalOrders': allOrders.length,
      'statusDistribution': statusDist,
      'mealTypeDistribution': mealTypeDist,
    };
  }

  // Get feedback by canteen
  static Future<Map<String, List<FeedbackModel>>> getFeedbackByCanteen() async {
    final allFeedback = await getAllFeedback();
    final grouped = <String, List<FeedbackModel>>{};

    for (var feedback in allFeedback) {
      if (!grouped.containsKey(feedback.canteenId)) {
        grouped[feedback.canteenId] = [];
      }
      grouped[feedback.canteenId]!.add(feedback);
    }

    return grouped;
  }

  // Get orders by canteen
  static Future<Map<String, List<OrderModel>>> getOrdersByCanteen() async {
    final allOrders = await getAllOrders();
    final grouped = <String, List<OrderModel>>{};

    for (var order in allOrders) {
      if (!grouped.containsKey(order.canteenId)) {
        grouped[order.canteenId] = [];
      }
      grouped[order.canteenId]!.add(order);
    }

    return grouped;
  }
}

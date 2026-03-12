import 'package:uuid/uuid.dart';
import 'firestore_service.dart';

class CanteenApiService {
  final FirestoreService _firestoreService = FirestoreService();
  static const uuid = Uuid();

  Future<List<Map<String, dynamic>>> getAllCanteens() async {
    try {
      return await _firestoreService.getAllCanteens();
    } catch (e) {
      throw Exception('Failed to fetch canteens: $e');
    }
  }

  Future<Map<String, dynamic>?> getCanteenById(String id) async {
    try {
      return await _firestoreService.getCanteen(id);
    } catch (e) {
      throw Exception('Failed to fetch canteen: $e');
    }
  }

  Future<Map<String, dynamic>> createCanteen(
    String ownerId,
    Map<String, dynamic> data,
  ) async {
    try {
      final canteenId = uuid.v4();
      final canteenData = {
        ...data,
        'owner': ownerId,
        'isActive': true,
        'rating': 0,
        'totalOrders': 0,
      };

      await _firestoreService.createCanteen(canteenId, canteenData);
      return {'id': canteenId, ...canteenData};
    } catch (e) {
      throw Exception('Failed to create canteen: $e');
    }
  }

  Future<Map<String, dynamic>> updateCanteen(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestoreService.updateCanteen(id, data);
      final updated = await _firestoreService.getCanteen(id);
      return updated ?? {};
    } catch (e) {
      throw Exception('Failed to update canteen: $e');
    }
  }

  Future<void> deleteCanteen(String id) async {
    try {
      await _firestoreService.deleteCanteen(id);
    } catch (e) {
      throw Exception('Failed to delete canteen: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOwnerCanteens(String ownerId) async {
    try {
      return await _firestoreService.getOwnerCanteens(ownerId);
    } catch (e) {
      throw Exception('Failed to fetch owner canteens: $e');
    }
  }
}

import 'package:uuid/uuid.dart';
import 'firestore_service.dart';

class MenuApiService {
  final FirestoreService _firestoreService = FirestoreService();
  static const uuid = Uuid();

  Future<List<Map<String, dynamic>>> getMenuByCanteen(
    String canteenId, {
    String? category,
  }) async {
    try {
      return await _firestoreService.getMenuByCanteen(
        canteenId,
        category: category,
      );
    } catch (e) {
      throw Exception('Failed to fetch menu: $e');
    }
  }

  Future<Map<String, dynamic>?> getMenuItemById(String id) async {
    try {
      return await _firestoreService.getMenuItem(id);
    } catch (e) {
      throw Exception('Failed to fetch menu item: $e');
    }
  }

  Future<Map<String, dynamic>> createMenuItem(
    String canteenId,
    Map<String, dynamic> data,
  ) async {
    try {
      final menuItemId = uuid.v4();
      final itemData = {
        ...data,
        'canteen': canteenId,
        'isAvailable': true,
        'rating': 0,
      };

      await _firestoreService.createMenuItem(menuItemId, itemData);
      return {'id': menuItemId, ...itemData};
    } catch (e) {
      throw Exception('Failed to create menu item: $e');
    }
  }

  Future<Map<String, dynamic>> updateMenuItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestoreService.updateMenuItem(id, data);
      final updated = await _firestoreService.getMenuItem(id);
      return updated ?? {};
    } catch (e) {
      throw Exception('Failed to update menu item: $e');
    }
  }

  Future<void> deleteMenuItem(String id) async {
    try {
      await _firestoreService.deleteMenuItem(id);
    } catch (e) {
      throw Exception('Failed to delete menu item: $e');
    }
  }
}

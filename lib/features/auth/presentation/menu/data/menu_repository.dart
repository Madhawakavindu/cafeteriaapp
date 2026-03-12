import 'package:cafeteria/features/auth/core/models/menu_item.dart';
import 'package:cafeteria/core/services/menu_api_service.dart';

class MenuRepository {
  static final MenuRepository _instance = MenuRepository._internal();
  final MenuApiService _menuApiService = MenuApiService();

  factory MenuRepository() {
    return _instance;
  }

  MenuRepository._internal();

  // Add menu item for a specific canteen and date
  Future<void> addMenuItem(String canteenId, MenuItem item) async {
    await _menuApiService.createMenuItem(canteenId, {
      'name': item.mainFood,
      'description': item.vegetables.join(', '),
      'category': 'daily',
      'mainFood': item.mainFood,
      'vegetables': item.vegetables,
      'mealType': item.mealType,
      'mealTime': item.mealTime,
      'date': item.date,
      'isAvailable': true,
    });
  }

  // Get menu items for a canteen on a specific date
  Future<List<MenuItem>> getMenuForDate(String canteenId, String date) async {
    final rawItems = await _menuApiService.getMenuByCanteen(canteenId);
    final items = rawItems
        .where((item) => (item['date']?.toString() ?? '') == date)
        .map(_mapToMenuItem)
        .toList();
    return items;
  }

  // Get all menu items for a canteen
  Future<List<MenuItem>> getAllMenuItems(String canteenId) async {
    final rawItems = await _menuApiService.getMenuByCanteen(canteenId);
    return rawItems.map(_mapToMenuItem).toList();
  }

  // Delete a menu item
  Future<void> deleteMenuItem(String canteenId, String itemId) async {
    await _menuApiService.deleteMenuItem(itemId);
  }

  // Update a menu item
  Future<void> updateMenuItem(String canteenId, MenuItem item) async {
    await _menuApiService.updateMenuItem(item.id, {
      'name': item.mainFood,
      'description': item.vegetables.join(', '),
      'mainFood': item.mainFood,
      'vegetables': item.vegetables,
      'mealType': item.mealType,
      'date': item.date,
    });
  }

  MenuItem _mapToMenuItem(Map<String, dynamic> item) {
    final vegetablesRaw = item['vegetables'];
    final vegetables = vegetablesRaw is List
        ? vegetablesRaw.map((e) => e.toString()).toList()
        : <String>[];

    return MenuItem(
      id: item['id']?.toString() ?? '',
      mainFood: item['mainFood']?.toString() ?? item['name']?.toString() ?? '',
      vegetables: vegetables,
      mealType: item['mealType']?.toString() ?? 'Vegetarian',
      mealTime: item['mealTime']?.toString() ?? 'Lunch',
      date: item['date']?.toString() ?? '',
    );
  }
}

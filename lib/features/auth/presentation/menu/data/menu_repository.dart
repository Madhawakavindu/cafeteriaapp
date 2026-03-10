import 'package:cafeteria/features/auth/core/models/menu_item.dart';

class MenuRepository {
  static final MenuRepository _instance = MenuRepository._internal();
  final Map<String, List<MenuItem>> _menuItems = {};

  factory MenuRepository() {
    return _instance;
  }

  MenuRepository._internal();

  // Add menu item for a specific canteen and date
  Future<void> addMenuItem(String canteenId, MenuItem item) async {
    if (!_menuItems.containsKey(canteenId)) {
      _menuItems[canteenId] = [];
    }
    _menuItems[canteenId]!.add(item);
  }

  // Get menu items for a canteen on a specific date
  Future<List<MenuItem>> getMenuForDate(String canteenId, String date) async {
    if (!_menuItems.containsKey(canteenId)) {
      return [];
    }
    return _menuItems[canteenId]!.where((item) => item.date == date).toList();
  }

  // Get all menu items for a canteen
  Future<List<MenuItem>> getAllMenuItems(String canteenId) async {
    if (!_menuItems.containsKey(canteenId)) {
      return [];
    }
    return _menuItems[canteenId]!;
  }

  // Delete a menu item
  Future<void> deleteMenuItem(String canteenId, String itemId) async {
    if (_menuItems.containsKey(canteenId)) {
      _menuItems[canteenId]!.removeWhere((item) => item.id == itemId);
    }
  }

  // Update a menu item
  Future<void> updateMenuItem(String canteenId, MenuItem item) async {
    if (_menuItems.containsKey(canteenId)) {
      final index = _menuItems[canteenId]!.indexWhere(
        (existingItem) => existingItem.id == item.id,
      );
      if (index != -1) {
        _menuItems[canteenId]![index] = item;
      }
    }
  }
}

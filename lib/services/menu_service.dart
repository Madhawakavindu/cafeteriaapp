import 'package:cafeteria/models/menu_item_model.dart';

class MenuService {
  // Mock data - replace with real API/Firebase calls
  static final List<MenuItemModel> _todayMenu = [
    MenuItemModel(
      id: '1',
      name: 'Biryani',
      description: 'Fragrant rice with chicken',
      vegetables: ['Onion', 'Tomato', 'Mint'],
      price: 150.0,
      isAvailable: true,
      quantity: 50,
      mealType: 'lunch',
    ),
    MenuItemModel(
      id: '2',
      name: 'Dosa',
      description: 'Crispy South Indian crepe',
      vegetables: ['Potato', 'Onion'],
      price: 80.0,
      isAvailable: true,
      quantity: 30,
      mealType: 'breakfast',
    ),
  ];

  // Get today's menu
  static Future<List<MenuItemModel>> getTodayMenu() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _todayMenu;
  }

  // Get available items only
  static Future<List<MenuItemModel>> getAvailableItems() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _todayMenu.where((item) => item.isAvailable && item.quantity > 0).toList();
  }

  // Update item availability
  static Future<void> updateAvailability(String itemId, bool isAvailable) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _todayMenu.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _todayMenu[index] = MenuItemModel(
        id: _todayMenu[index].id,
        name: _todayMenu[index].name,
        description: _todayMenu[index].description,
        vegetables: _todayMenu[index].vegetables,
        price: _todayMenu[index].price,
        imageUrl: _todayMenu[index].imageUrl,
        isAvailable: isAvailable,
        quantity: _todayMenu[index].quantity,
        mealType: _todayMenu[index].mealType,
      );
    }
  }

  // Update quantity
  static Future<void> updateQuantity(String itemId, int quantity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _todayMenu.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _todayMenu[index] = MenuItemModel(
        id: _todayMenu[index].id,
        name: _todayMenu[index].name,
        description: _todayMenu[index].description,
        vegetables: _todayMenu[index].vegetables,
        price: _todayMenu[index].price,
        imageUrl: _todayMenu[index].imageUrl,
        isAvailable: _todayMenu[index].isAvailable,
        quantity: quantity,
        mealType: _todayMenu[index].mealType,
      );
    }
  }
}

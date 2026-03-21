import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/features/auth/core/services/auth_service.dart';
import 'package:cafeteria/features/auth/core/models/menu_item.dart';
import 'package:cafeteria/features/auth/presentation/menu/data/menu_repository.dart';
import 'package:cafeteria/features/auth/presentation/screens/add_menu_item_screen.dart';

class AdminMenuScreen extends StatefulWidget {
  final String canteenId;

  const AdminMenuScreen({required this.canteenId, super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final _repository = MenuRepository();
  final _authService = AuthService();
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _guardAccess();
    _loadMenuItems();
  }

  void _guardAccess() {
    final user = _authService.currentUser;
    if (user == null ||
        user.role != 'owner' ||
        user.canteenId != widget.canteenId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Access denied. You can only manage your own canteen menu.',
            ),
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> _loadMenuItems() async {
    final user = _authService.currentUser;
    if (user == null ||
        user.role != 'owner' ||
        user.canteenId != widget.canteenId) {
      setState(() => _errorMessage = 'Access denied for this canteen.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final today = DateTime.now().toString().split(' ')[0];
      final items = await _repository.getMenuForDate(widget.canteenId, today);
      setState(() => _menuItems = items);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load menu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMenuItem(String itemId) async {
    await _repository.deleteMenuItem(widget.canteenId, itemId);
    _loadMenuItems();
  }

  Future<void> _navigateToAddMenu() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMenuItemScreen(canteenId: widget.canteenId),
      ),
    );
    if (result != null) {
      _loadMenuItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Menu (Admin)"),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMenu,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMenuItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _menuItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No menu items for today',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddMenu,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Menu Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.mainFood,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.mealType == 'Vegetarian'
                                          ? Colors.green.withValues(alpha: 0.2)
                                          : Colors.red.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.mealType,
                                      style: TextStyle(
                                        color: item.mealType == 'Vegetarian'
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteMenuItem(item.id),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vegetables: ${item.vegetables.join(', ')}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

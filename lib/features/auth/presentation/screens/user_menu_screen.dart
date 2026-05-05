import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/features/auth/core/models/menu_item.dart';
import 'package:cafeteria/features/auth/presentation/feedback/data/presentation/screens/leave_feedback_screen.dart';
import 'package:cafeteria/features/auth/presentation/feedback/data/presentation/screens/feedback_list_screen.dart';
import 'package:cafeteria/features/auth/presentation/menu/data/menu_repository.dart';
import 'package:cafeteria/features/auth/presentation/order/presentation/order_screen.dart';

class UserMenuScreen extends StatefulWidget {
  final String canteenName;
  final String canteenId;

  const UserMenuScreen({
    required this.canteenName,
    required this.canteenId,
    super.key,
  });

  @override
  State<UserMenuScreen> createState() => _UserMenuScreenState();
}

class _UserMenuScreenState extends State<UserMenuScreen> {
  final _repository = MenuRepository();
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final today = DateTime.now().toString().split(' ')[0];
      final items = await _repository.getMenuForDate(widget.canteenId, today);
      setState(() => _menuItems = items);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load menu. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.canteenName} - Today's Menu"),
        backgroundColor: AppColors.primary,
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
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                    'No menu items available today',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadMenuItems,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _buildMealTimeSections(),
              ),
            ),
    );
  }

  List<Widget> _buildMealTimeSections() {
    const mealTimes = ['Breakfast', 'Lunch', 'Dinner'];
    final List<Widget> widgets = [];

    for (final mealTime in mealTimes) {
      final items = _menuItems.where((i) => i.mealTime == mealTime).toList();
      if (items.isEmpty) continue;
      widgets.add(_MealTimeSectionHeader(mealTime: mealTime));
      widgets.addAll(items.map((item) => _buildItemCard(item)));
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }

  Widget _buildItemCard(MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.mealType == 'Vegetarian'
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.mealType,
                          style: TextStyle(
                            color: item.mealType == 'Vegetarian'
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMealTypeBadge(item.mealType),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              'Vegetables:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.vegetables
                  .map(
                    (veg) => Chip(
                      label: Text(veg),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderScreen(
                            item: item,
                            canteenId: widget.canteenId,
                            canteenName: widget.canteenName,
                          ),
                        ),
                      );
                      if (!mounted || result == null) return;
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Order placed successfully'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Order Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LeaveFeedbackScreen(
                            menuItemId: item.id,
                            menuItemName: item.mainFood,
                            canteenId: widget.canteenId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review_outlined, size: 16),
                    label: const Text(
                      'Feedback',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FeedbackListScreen(
                          menuItemId: item.id,
                          menuItemName: item.mainFood,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                  ),
                  child: const Icon(Icons.comment_outlined, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeBadge(String mealType) {
    if (mealType == 'Vegetarian') {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          margin: const EdgeInsets.all(2),
        ),
      );
    } else {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          margin: const EdgeInsets.all(2),
        ),
      );
    }
  }
}

class _MealTimeSectionHeader extends StatelessWidget {
  final String mealTime;

  const _MealTimeSectionHeader({required this.mealTime});

  @override
  Widget build(BuildContext context) {
    final config = _mealTimeConfig(mealTime);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: config['color'] as Color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              config['icon'] as IconData,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            config['label'] as String,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(color: config['color'] as Color, thickness: 1.5),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _mealTimeConfig(String mealTime) {
    switch (mealTime) {
      case 'Breakfast':
        return {
          'icon': Icons.wb_sunny_outlined,
          'color': Colors.orange,
          'label': 'Breakfast',
        };
      case 'Dinner':
        return {
          'icon': Icons.nights_stay,
          'color': Colors.indigo,
          'label': 'Dinner',
        };
      default:
        return {
          'icon': Icons.wb_sunny,
          'color': Colors.amber[700]!,
          'label': 'Lunch',
        };
    }
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/core/services/firestore_service.dart';
import 'package:cafeteria/features/auth/presentation/canteen_selection/presentation/canteen_select_screen.dart';
import 'package:cafeteria/features/auth/presentation/order/order_history_screen.dart';
import 'package:cafeteria/features/auth/presentation/feedback/feedback_screen.dart';
import 'package:cafeteria/features/auth/presentation/feedback/data/presentation/screens/feedback_list_screen.dart';
import 'package:cafeteria/features/auth/presentation/profile/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, List<Map<String, dynamic>>>> _todayRatedFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _todayRatedFuture = FirestoreService().getTodayRatedItemsByCategory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Cafeteria'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              const Text(
                'Welcome!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Campus Cafeteria App',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _TodaysRatedItemsSection(
                todayRatedFuture: _todayRatedFuture,
                onRefresh: _refreshData,
              ),
              const SizedBox(height: 24),
              _MenuCard(
                icon: Icons.restaurant_menu,
                title: 'Select Canteen',
                subtitle: 'Choose your canteen and view menu',
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CanteenSelectScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _MenuCard(
                icon: Icons.receipt_long,
                title: 'My Orders',
                subtitle: 'View your order history',
                color: AppColors.accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrderHistoryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _MenuCard(
                icon: Icons.feedback,
                title: 'Feedback',
                subtitle: 'Share your feedback',
                color: AppColors.canteen1,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _MenuCard(
                icon: Icons.person,
                title: 'Profile',
                subtitle: 'Manage your account',
                color: AppColors.canteen2,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodaysRatedItemsSection extends StatefulWidget {
  final Future<Map<String, List<Map<String, dynamic>>>> todayRatedFuture;
  final VoidCallback onRefresh;

  const _TodaysRatedItemsSection({
    required this.todayRatedFuture,
    required this.onRefresh,
  });

  @override
  State<_TodaysRatedItemsSection> createState() =>
      _TodaysRatedItemsSectionState();
}

class _TodaysRatedItemsSectionState extends State<_TodaysRatedItemsSection> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  List<Map<String, dynamic>> _allItems = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_allItems.isEmpty) return;
      _currentPage = (_currentPage + 1) % _allItems.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onItemTap(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackListScreen(
          menuItemId: (item['menuItemId'] ?? '').toString(),
          menuItemName: (item['menuItemName'] ?? 'Unknown Item').toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: widget.todayRatedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 4,
            color: Colors.orange.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Loading today\'s rated food...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            elevation: 4,
            color: Colors.red.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Unable to load today\'s rated food.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final grouped = snapshot.data ?? {};
        if (grouped.isEmpty) {
          _autoScrollTimer?.cancel();
          return Card(
            elevation: 4,
            color: Colors.orange.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Text(
                        'Today\'s Rated Items',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No ratings have been submitted today yet.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }

        // Flatten all items from all categories into a single list
        _allItems = <Map<String, dynamic>>[];
        grouped.forEach((_, items) => _allItems.addAll(items));

        // Start auto-scroll if we have items
        if (_allItems.isNotEmpty) {
          _startAutoScroll();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Text(
                        'Today\'s Rated Items (${_allItems.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: widget.onRefresh,
                    icon: const Icon(Icons.refresh, color: Colors.deepOrange),
                    tooltip: 'Refresh',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minHeight: 24,
                      minWidth: 24,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: RefreshIndicator(
                onRefresh: () async {
                  widget.onRefresh();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _allItems.length,
                  itemBuilder: (context, index) {
                    final item = _allItems[index];
                    final menuItemName =
                        (item['menuItemName'] ?? 'Unknown Item').toString();
                    final ratingCount = (item['ratingCount'] as int?) ?? 0;
                    final avgRating = (item['avgRating'] as double?) ?? 0.0;

                    return GestureDetector(
                      onTap: () => _onItemTap(item),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.orange.shade100,
                                  Colors.amber.shade100,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      menuItemName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade300,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${avgRating.toStringAsFixed(1)} / 5',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.shade400,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$ratingCount ${ratingCount == 1 ? 'rating' : 'ratings'} today',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _allItems.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.deepOrange
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

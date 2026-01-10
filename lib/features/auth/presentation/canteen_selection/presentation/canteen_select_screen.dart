import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/features/auth/presentation/screens/user_menu_screen.dart';

class CanteenSelectScreen extends StatelessWidget {
  const CanteenSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> canteens = [
      {'name': 'Canteen 1', 'color': AppColors.canteen1, 'id': 'Canteen1'},
      {'name': 'Canteen 2', 'color': AppColors.canteen2, 'id': 'Canteen2'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Canteen'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Add big image
            // Image.asset('assets/images/canteen_banner.png', height: 200),
            const Text('Select Your Canteen', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 50),
            ...canteens.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 10,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c['color'],
                    padding: const EdgeInsets.all(20),
                  ),
                  onPressed: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserMenuScreen(canteenName: c['name']),
                      ),
                    );
                  },
                  child: Text(
                    c['name'],
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

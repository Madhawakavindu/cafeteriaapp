import 'package:cafeteria/features/auth/presentation/menu/data/presentation/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import '/core/constants/app_colors.dart';
import '/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cafeteria/features/auth/presentation/widgets/auth_form.dart';

class CanteenSelectScreen extends StatelessWidget {
  const CanteenSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> canteens = [
      {'name': 'Canteen 1', 'color': AppColors.canteen1, 'id': 'Canteen1'},
      {'name': 'Canteen 2', 'color': AppColors.canteen2, 'id': 'Canteen2'},
    ];

    return Scaffold(
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
                    await FirestoreService().users
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({'selectedCanteen': c['id']});
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MenuScreen()),
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

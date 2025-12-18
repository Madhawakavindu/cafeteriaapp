import 'package:cafeteria/features/auth/presentation/menu/data/menu_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  final String canteenId, date, mealType, foodName;
  const MealDetailScreen({
    required this.canteenId,
    required this.date,
    required this.mealType,
    required this.foodName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(foodName)),
      body: StreamBuilder<DocumentSnapshot>(
        stream: MenuRepository().getMeal(canteenId, date, mealType, foodName),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final veggies = List<String>.from(data['vegetables'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: Add food image here
                // Image.asset('assets/images/$foodName.jpg', height: 200, width: double.infinity, fit: BoxFit.cover),
                const SizedBox(height: 20),
                Text(
                  data['description'] ?? 'Delicious $foodName',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Vegetables/Sides:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: veggies.map((v) => Chip(label: Text(v))).toList(),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/leave_feedback',
                    arguments: {'canteenId': canteenId, 'food': foodName},
                  ),
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Leave Feedback'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

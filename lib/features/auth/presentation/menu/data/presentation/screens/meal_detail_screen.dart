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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Meal: $foodName'),
            const SizedBox(height: 20),
            const Text('Details coming soon'),
          ],
        ),
      ),
    );
  }
}

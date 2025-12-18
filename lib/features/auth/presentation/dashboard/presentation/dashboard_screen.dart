import 'package:cafeteria/core/widgets/rating_stars.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canteen Battle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TODO: Add trophy image
            // Image.asset('assets/images/trophy.png', height: 150),
            const Text(
              'Canteen Battle Leaderboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _LeaderboardItem(
              name: 'Canteen 1',
              rating: 4.6,
              color: Colors.green,
            ),
            _LeaderboardItem(
              name: 'Canteen 2',
              rating: 4.2,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final String name;
  final double rating;
  final Color color;
  const _LeaderboardItem({
    required this.name,
    required this.rating,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, child: Text(name[8])),
        title: Text(name, style: const TextStyle(fontSize: 22)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingStars(rating),
            const SizedBox(width: 8),
            Text(rating.toString(), style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

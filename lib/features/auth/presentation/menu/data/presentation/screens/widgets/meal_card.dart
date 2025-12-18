import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final String title;
  final List<String> items;
  const MealCard({required this.title, required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: items
            .map(
              (item) => ListTile(
                leading: const Icon(Icons.arrow_right),
                title: Text(item),
              ),
            )
            .toList(),
      ),
    );
  }
}

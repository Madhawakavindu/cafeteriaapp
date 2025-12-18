import 'package:flutter/material.dart';

class VegetableChip extends StatelessWidget {
  final String name;
  const VegetableChip(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(name),
      backgroundColor: Colors.green[100],
      avatar: const Icon(Icons.eco, size: 18, color: Colors.green),
    );
  }
}

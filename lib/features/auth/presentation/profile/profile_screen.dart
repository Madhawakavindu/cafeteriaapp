import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.canteen2,
      ),
      body: const Center(child: Text('No user loaded')),
    );
  }
}

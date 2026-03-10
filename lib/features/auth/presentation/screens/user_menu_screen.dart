import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';

class UserMenuScreen extends StatelessWidget {
  final String canteenName;

  const UserMenuScreen({required this.canteenName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$canteenName - Today's Menu"),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text(
          'No items available today',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}

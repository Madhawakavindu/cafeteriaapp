import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Menu (Admin)"),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Text('No menu items', style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}

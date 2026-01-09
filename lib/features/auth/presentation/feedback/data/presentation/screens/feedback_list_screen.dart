import 'package:flutter/material.dart';

class FeedbackListScreen extends StatelessWidget {
  final String canteenId;
  const FeedbackListScreen(this.canteenId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Feedback coming soon', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          const Text('Feedback will be displayed here'),
        ],
      ),
    );
  }
}

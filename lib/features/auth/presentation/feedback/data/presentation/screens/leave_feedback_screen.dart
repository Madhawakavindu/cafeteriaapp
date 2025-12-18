import 'package:cafeteria/core/widgets/custom_button.dart';
import 'package:cafeteria/core/widgets/rating_stars.dart';
import 'package:cafeteria/features/auth/presentation/feedback/data/feedback_repository.dart';
import 'package:flutter/material.dart';

class LeaveFeedbackScreen extends StatefulWidget {
  @override
  State<LeaveFeedbackScreen> createState() => _LeaveFeedbackScreenState();
}

class _LeaveFeedbackScreenState extends State<LeaveFeedbackScreen> {
  int rating = 3;
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final canteenId = args['canteenId'];
    final food = args['food'];

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('How was your $food?', style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            RatingStars(rating.toDouble()),
            Slider(
              value: rating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => rating = v.round()),
            ),
            TextField(
              controller: commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Submit Feedback',
              onPressed: () async {
                await FeedbackRepository().submitFeedback(
                  canteenId,
                  food,
                  commentController.text,
                  rating,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Thank you!')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

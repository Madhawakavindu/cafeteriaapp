import 'package:cafeteria/core/widgets/rating_stars.dart';
import 'package:cafeteria/features/auth/presentation/feedback/data/feedback_repository.dart';
import 'package:flutter/material.dart';

class FeedbackListScreen extends StatelessWidget {
  final String canteenId;
  const FeedbackListScreen(this.canteenId, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FeedbackRepository().getFeedback(canteenId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final feedbacks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: feedbacks.length,
          itemBuilder: (ctx, i) {
            final data = feedbacks[i].data() as Map<String, dynamic>;
            return ListTile(
              leading: RatingStars(data['rating'].toDouble()),
              title: Text(data['comment'] ?? 'No comment'),
              subtitle: Text(data['food']),
            );
          },
        );
      },
    );
  }
}

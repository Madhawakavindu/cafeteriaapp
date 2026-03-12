import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/core/widgets/custom_button.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _controller = TextEditingController();
  double _rating = 0;
  String _selectedCanteen = 'Canteen1';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: AppColors.canteen1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select canteen'),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedCanteen,
              items: const [
                DropdownMenuItem(value: 'Canteen1', child: Text('Canteen 1')),
                DropdownMenuItem(value: 'Canteen2', child: Text('Canteen 2')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCanteen = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Rate your experience'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final filled = i + 1 <= _rating.round();
                return IconButton(
                  icon: Icon(
                    filled ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = (i + 1).toDouble()),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Your feedback'),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your feedback here',
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Submit',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback submitted')),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Recent feedback'),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Text(
                  'No feedback yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

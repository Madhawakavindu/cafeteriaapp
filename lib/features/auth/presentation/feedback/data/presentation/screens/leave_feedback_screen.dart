import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/features/auth/core/services/auth_service.dart';
import 'package:cafeteria/features/auth/presentation/feedback/data/feedback_repository.dart';
import 'package:cafeteria/features/auth/presentation/feedback/data/presentation/screens/feedback_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';

class LeaveFeedbackScreen extends StatefulWidget {
  final String menuItemId;
  final String menuItemName;
  final String canteenId;

  const LeaveFeedbackScreen({
    required this.menuItemId,
    required this.menuItemName,
    required this.canteenId,
    super.key,
  });

  @override
  State<LeaveFeedbackScreen> createState() => _LeaveFeedbackScreenState();
}

class _LeaveFeedbackScreenState extends State<LeaveFeedbackScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Try AuthService first; fall back to FirebaseAuth directly
    final authUser = AuthService().currentUser;
    final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;

    final userId = authUser?.id ?? firebaseUser?.uid;
    final userName = authUser?.name ?? firebaseUser?.displayName ?? 'Anonymous';

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in again to submit feedback.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await FeedbackRepository().submitFeedback(
        menuItemId: widget.menuItemId,
        menuItemName: widget.menuItemName,
        canteenId: widget.canteenId,
        userId: userId,
        userName: userName,
        rating: _rating,
        comment: _commentController.text.trim(),
        date: DateTime.now().toString().split(' ')[0],
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted! Thank you.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Feedback'),
        backgroundColor: AppColors.primary,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FeedbackListScreen(
                    menuItemId: widget.menuItemId,
                    menuItemName: widget.menuItemName,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.comment_outlined, color: Colors.white),
            label: const Text(
              'View All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.menuItemName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'How was this dish?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Rating',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _ratingLabel(_rating),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Comment (optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your thoughts about this dish...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1:
        return 'Very Bad';
      case 2:
        return 'Bad';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }
}

// Placeholder to satisfy old route-based calls if any
class OldLeaveFeedbackScreen extends StatelessWidget {
  const OldLeaveFeedbackScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Use LeaveFeedbackScreen with named params.')),
    );
  }
}

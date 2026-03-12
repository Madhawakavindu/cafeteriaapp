import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OwnerFeedbackScreen extends StatelessWidget {
  final String canteenId;
  final String canteenName;

  const OwnerFeedbackScreen({
    required this.canteenId,
    required this.canteenName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$canteenName — Feedback'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().watchFeedbackForCanteen(canteenId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final feedbacks = snapshot.data ?? [];

          // Sort newest first in memory
          feedbacks.sort((a, b) {
            final ta = a['createdAt'];
            final tb = b['createdAt'];
            if (ta == null || tb == null) return 0;
            try {
              return (tb as Timestamp).compareTo(ta as Timestamp);
            } catch (_) {
              return 0;
            }
          });

          if (feedbacks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No feedback yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Customer feedback will appear here',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // compute avg rating
          final avgRating =
              feedbacks.fold<double>(
                0,
                (acc, f) => acc + ((f['rating'] as num?)?.toDouble() ?? 0),
              ) /
              feedbacks.length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSummary(feedbacks, avgRating)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _FeedbackCard(data: feedbacks[i]),
                    childCount: feedbacks.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummary(List feedbacks, double avgRating) {
    // Group by dish
    final Map<String, List<dynamic>> byDish = {};
    for (final f in feedbacks) {
      final name = (f['menuItemName'] as String?) ?? 'Unknown';
      byDish.putIfAbsent(name, () => []).add(f);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < avgRating.round() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${feedbacks.length} review${feedbacks.length == 1 ? '' : 's'} total',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'By Dish',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...byDish.entries.map((entry) {
            final dishAvg =
                entry.value.fold<double>(
                  0,
                  (acc, f) => acc + ((f['rating'] as num?)?.toDouble() ?? 0),
                ) /
                entry.value.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < dishAvg.round() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 14,
                      );
                    }),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${dishAvg.toStringAsFixed(1)} (${entry.value.length})',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _FeedbackCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final rating = (data['rating'] as int?) ?? 0;
    final comment = (data['comment'] as String?) ?? '';
    final userName = (data['userName'] as String?) ?? 'Anonymous';
    final dishName = (data['menuItemName'] as String?) ?? '';
    final date = _formatDate(data['createdAt']);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.15,
                      ),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (dishName.isNotEmpty)
                          Text(
                            dishName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                comment,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as Timestamp).toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

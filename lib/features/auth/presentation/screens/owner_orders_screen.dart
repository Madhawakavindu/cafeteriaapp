import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/core/services/firestore_service.dart';
import 'package:cafeteria/core/services/order_api_service.dart';

class OwnerOrdersScreen extends StatefulWidget {
  final String canteenId;
  final String canteenName;

  const OwnerOrdersScreen({
    required this.canteenId,
    required this.canteenName,
    super.key,
  });

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final OrderApiService _orderApiService = OrderApiService();
  String? _updatingOrderId;

  Future<void> _updateStatus(String orderId, String status) async {
    setState(() => _updatingOrderId = orderId);
    try {
      await _orderApiService.updateOrderStatus(orderId, status);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order marked as $status')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    } finally {
      if (mounted) {
        setState(() => _updatingOrderId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.canteenName} Orders'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.watchCanteenOrders(widget.canteenId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load incoming orders.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final orders = snapshot.data ?? [];
          orders.sort((a, b) {
            final ta = a['createdAt'];
            final tb = b['createdAt'];
            if (ta is Timestamp && tb is Timestamp) {
              return tb.compareTo(ta);
            }
            return 0;
          });

          if (orders.isEmpty) {
            return const Center(child: Text('No incoming orders yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['id']?.toString() ?? '';
              final status = order['status']?.toString() ?? 'pending';
              final isUpdating = _updatingOrderId == orderId;

              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order['menuItemName']?.toString() ?? 'Order',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                status,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Order No: ${order['orderNumber'] ?? '-'}'),
                      Text('Quantity: ${order['quantity'] ?? 1}'),
                      Text('Meal Time: ${order['mealTime'] ?? '-'}'),
                      Text('Payment: ${order['paymentStatus'] ?? 'pending'}'),
                      if (order['notes'] != null &&
                          order['notes'].toString().trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Notes: ${order['notes']}'),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isUpdating || status == 'preparing'
                                  ? null
                                  : () => _updateStatus(orderId, 'preparing'),
                              child: const Text('Mark Preparing'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isUpdating || status == 'completed'
                                  ? null
                                  : () => _updateStatus(orderId, 'completed'),
                              child: isUpdating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Mark Completed'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'preparing':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }
}

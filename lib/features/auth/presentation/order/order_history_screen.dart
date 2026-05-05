import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/core/services/firestore_service.dart';
import 'package:cafeteria/core/services/order_api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderApiService _orderApiService = OrderApiService();
  String? _processingOrderId;

  Future<void> _markAsReceived(String orderId) async {
    setState(() => _processingOrderId = orderId);
    try {
      await _orderApiService.markOrderReceived(orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as received.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark order as received: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _processingOrderId = null);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // using real-time stream; no initial load required
  }

  Future<void> _refresh() async {
    // no-op; stream updates automatically
    return Future.value();
  }

  // using stream-based updates; no manual load method required

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppColors.accent,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Builder(
          builder: (context) {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Please sign in to view your orders')),
                ],
              );
            }

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService().watchUserOrders(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  final details = snapshot.error?.toString() ?? '';
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 120),
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load orders. Please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          details,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  );
                }

                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('No orders yet')),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final orderId = order['id']?.toString() ?? '';
                    final status = order['status']?.toString() ?? 'pending';
                    final isProcessing = _processingOrderId == orderId;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['menuItemName']?.toString() ?? 'Order',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Order No: ${order['orderNumber'] ?? '-'}'),
                            Text('Quantity: ${order['quantity'] ?? 1}'),
                            Text('Status: $status'),
                            Text(
                              'Payment: ${order['paymentStatus'] ?? 'pending'}',
                            ),
                            if (order['notes'] != null &&
                                order['notes'].toString().trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('Notes: ${order['notes']}'),
                              ),
                            if (status == 'completed') ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: isProcessing || orderId.isEmpty
                                      ? null
                                      : () => _markAsReceived(orderId),
                                  icon: isProcessing
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.check_circle_outline),
                                  label: Text(
                                    isProcessing
                                        ? 'Updating...'
                                        : 'Mark as Received',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

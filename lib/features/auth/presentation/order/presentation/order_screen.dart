import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/core/services/order_api_service.dart';
import 'package:cafeteria/features/auth/core/models/menu_item.dart';
import 'package:cafeteria/features/auth/presentation/order/order_history_screen.dart';

class OrderScreen extends StatefulWidget {
  final MenuItem item;
  final String canteenId;
  final String canteenName;

  const OrderScreen({
    required this.item,
    required this.canteenId,
    required this.canteenName,
    super.key,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _orderApiService = OrderApiService();
  final _notesController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  int _quantity = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to place an order.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final order = await _orderApiService.createOrder(currentUser.uid, {
        'canteen': widget.canteenId,
        'canteenName': widget.canteenName,
        'menuItemId': widget.item.id,
        'menuItemName': widget.item.mainFood,
        'vegetables': widget.item.vegetables,
        'mealType': widget.item.mealType,
        'mealTime': widget.item.mealTime,
        'date': widget.item.date,
        'quantity': _quantity,
        'notes': _notesController.text.trim(),
      });

      if (!mounted) return;
      // Close order form and then open Order History so user can see the placed order
      Navigator.pop(context, order);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Order'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.mainFood,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Canteen: ${widget.canteenName}'),
                    Text('Meal time: ${widget.item.mealTime}'),
                    Text('Meal type: ${widget.item.mealType}'),
                    const SizedBox(height: 8),
                    Text('Vegetables: ${widget.item.vegetables.join(', ')}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quantity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  width: 72,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Special notes',
                hintText: 'Example: less spicy, extra rice',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.primary.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Item: ${widget.item.mainFood}'),
                    Text('Quantity: $_quantity'),
                    Text('Customer: ${currentUser?.email ?? 'Unknown user'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        'Place Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

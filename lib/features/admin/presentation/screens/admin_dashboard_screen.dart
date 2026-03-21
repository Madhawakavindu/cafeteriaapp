import 'package:flutter/material.dart';
import 'package:cafeteria/core/services/owner_request_service.dart';
import 'package:cafeteria/features/auth/core/services/auth_service.dart';
import 'package:cafeteria/features/auth/presentation/screens/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final OwnerRequestService _ownerRequestService = OwnerRequestService();
  final AuthService _authService = AuthService();
  String? _processingRequestId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        elevation: 0,
        backgroundColor: const Color(0xFF6366F1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ownerRequestService.watchPendingRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load requests.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final pendingRequests = snapshot.data ?? [];
          if (pendingRequests.isEmpty) {
            return Center(
              child: Text(
                'No pending owner requests',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              final requestId = request['id']?.toString() ?? '';
              final userId = request['userId']?.toString() ?? '';
              final canteenId = request['canteenId']?.toString() ?? '';
              final canteenName = request['canteenName']?.toString() ?? '-';
              final userName = request['userName']?.toString() ?? '-';
              final userEmail = request['userEmail']?.toString() ?? '-';
              final note = request['note']?.toString() ?? '';

              final isProcessing = _processingRequestId == requestId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(userEmail),
                      const SizedBox(height: 8),
                      Text('Requested canteen: $canteenName'),
                      const SizedBox(height: 4),
                      Text('Canteen ID: $canteenId'),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Note: $note'),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () => _reviewRequest(
                                      requestId: requestId,
                                      userId: userId,
                                      canteenId: canteenId,
                                      canteenName: canteenName,
                                      approve: false,
                                    ),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () => _reviewRequest(
                                      requestId: requestId,
                                      userId: userId,
                                      canteenId: canteenId,
                                      canteenName: canteenName,
                                      approve: true,
                                    ),
                              child: isProcessing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Approve'),
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

  Future<void> _reviewRequest({
    required String requestId,
    required String userId,
    required String canteenId,
    required String canteenName,
    required bool approve,
  }) async {
    setState(() => _processingRequestId = requestId);

    try {
      if (approve) {
        await _ownerRequestService.approveRequest(
          requestId: requestId,
          userId: userId,
          canteenId: canteenId,
          canteenName: canteenName,
        );
      } else {
        await _ownerRequestService.rejectRequest(
          requestId: requestId,
          userId: userId,
          canteenId: canteenId,
          canteenName: canteenName,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? 'Request approved and owner role assigned.'
                : 'Request rejected.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _processingRequestId = null);
      }
    }
  }
}

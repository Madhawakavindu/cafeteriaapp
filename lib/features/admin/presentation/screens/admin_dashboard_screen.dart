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
  String? _removingOwnerId;

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pending Owner Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _ownerRequestService.watchPendingRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Failed to load requests.\n${snapshot.error}');
              }

              final pendingRequests = snapshot.data ?? [];
              if (pendingRequests.isEmpty) {
                return Text(
                  'No pending owner requests',
                  style: TextStyle(color: Colors.grey[600]),
                );
              }

              return Column(
                children: pendingRequests.map((request) {
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
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Current Owners',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _ownerRequestService.watchCurrentOwners(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Failed to load owners.\n${snapshot.error}');
              }

              final owners = snapshot.data ?? [];
              if (owners.isEmpty) {
                return Text(
                  'No owners assigned yet',
                  style: TextStyle(color: Colors.grey[600]),
                );
              }

              return Column(
                children: owners.map((owner) {
                  final userId = owner['id']?.toString() ?? '';
                  final name = owner['name']?.toString() ?? '-';
                  final email = owner['email']?.toString() ?? '-';
                  final canteenName = owner['canteenName']?.toString() ?? '-';
                  final isRemoving = _removingOwnerId == userId;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(name),
                      subtitle: Text('$email\nCanteen: $canteenName'),
                      isThreeLine: true,
                      trailing: OutlinedButton(
                        onPressed: isRemoving
                            ? null
                            : () => _confirmRemoveOwner(
                                userId: userId,
                                ownerName: name,
                              ),
                        child: isRemoving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Remove'),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveOwner({
    required String userId,
    required String ownerName,
  }) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Owner Access'),
        content: Text(
          'Are you sure you want to remove owner access for $ownerName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldRemove != true) return;

    await _removeOwnerAccess(userId);
  }

  Future<void> _removeOwnerAccess(String userId) async {
    setState(() => _removingOwnerId = userId);

    try {
      await _ownerRequestService.removeOwnerAccess(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner access removed successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _removingOwnerId = null);
      }
    }
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

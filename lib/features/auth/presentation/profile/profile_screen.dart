import 'package:flutter/material.dart';
import 'package:cafeteria/core/constants/app_colors.dart';
import 'package:cafeteria/core/services/user_api_service.dart';
import 'package:cafeteria/core/services/owner_request_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserApiService _userApiService = UserApiService();
  final OwnerRequestService _ownerRequestService = OwnerRequestService();

  final List<Map<String, String>> _availableCanteens = const [
    {'id': 'canteen_1', 'name': 'Main Cafeteria'},
    {'id': 'canteen_2', 'name': 'Secondary Cafeteria'},
  ];

  bool _isSubmittingRequest = false;
  Future<Map<String, dynamic>?>? _profileFuture;
  Future<Map<String, dynamic>?>? _requestFuture;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  void _reloadData() {
    setState(() {
      _profileFuture = _userApiService.getUserProfile();
      _requestFuture = _ownerRequestService.getLatestMyRequest();
    });
  }

  Future<void> _showOwnerRequestDialog() async {
    String selectedCanteenId = _availableCanteens.first['id']!;
    String selectedCanteenName = _availableCanteens.first['name']!;
    final noteController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Request Owner Access'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select canteen you want to manage:'),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setLocalState) {
                  return DropdownButtonFormField<String>(
                    initialValue: selectedCanteenId,
                    items: _availableCanteens
                        .map(
                          (canteen) => DropdownMenuItem<String>(
                            value: canteen['id'],
                            child: Text(canteen['name'] ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      final selected = _availableCanteens.firstWhere(
                        (canteen) => canteen['id'] == value,
                      );
                      setLocalState(() {
                        selectedCanteenId = selected['id']!;
                        selectedCanteenName = selected['name']!;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'Any details for admin',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _submitOwnerRequest(
                  canteenId: selectedCanteenId,
                  canteenName: selectedCanteenName,
                  note: noteController.text.trim(),
                );
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitOwnerRequest({
    required String canteenId,
    required String canteenName,
    required String note,
  }) async {
    setState(() => _isSubmittingRequest = true);

    try {
      await _ownerRequestService.submitOwnerRequest(
        canteenId: canteenId,
        canteenName: canteenName,
        note: note,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner request sent to admin.')),
      );
      _reloadData();
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isSubmittingRequest = false);
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.canteen2,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load profile.\n${profileSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = profileSnapshot.data;
          if (profile == null) {
            return const Center(child: Text('No user loaded'));
          }

          final role = (profile['role'] ?? 'user').toString();
          final isOwner = role == 'owner';

          return RefreshIndicator(
            onRefresh: () async => _reloadData(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  profile['name']?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(profile['email']?.toString() ?? '-'),
                const SizedBox(height: 12),
                Chip(
                  label: Text('Role: ${role.toUpperCase()}'),
                  backgroundColor: isOwner
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.blue.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 24),
                if (isOwner)
                  Card(
                    child: ListTile(
                      title: const Text('Assigned Canteen'),
                      subtitle: Text(
                        profile['canteenName']?.toString() ??
                            'No canteen assigned',
                      ),
                    ),
                  ),
                if (!isOwner)
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _requestFuture,
                    builder: (context, requestSnapshot) {
                      if (requestSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        );
                      }

                      final request = requestSnapshot.data;
                      final status = (request?['status'] ?? 'none').toString();
                      final hasPending = status == 'pending';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Owner Access',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (request != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      status,
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Latest request: ${status.toUpperCase()}',
                                    style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                const Text('No owner request sent yet.'),
                              const SizedBox(height: 8),
                              if (request != null)
                                Text(
                                  'Canteen: ${request['canteenName'] ?? '-'}',
                                ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      (_isSubmittingRequest || hasPending)
                                      ? null
                                      : _showOwnerRequestDialog,
                                  child: _isSubmittingRequest
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          hasPending
                                              ? 'Request Pending Approval'
                                              : 'Request Owner Access',
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

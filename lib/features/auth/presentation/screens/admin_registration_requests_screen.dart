import 'package:flutter/material.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../data/auth_api.dart';

/// Admin-only: list pending pilot registrations and approve or reject.
class AdminRegistrationRequestsScreen extends StatefulWidget {
  const AdminRegistrationRequestsScreen({super.key});

  @override
  State<AdminRegistrationRequestsScreen> createState() => _AdminRegistrationRequestsScreenState();
}

class _AdminRegistrationRequestsScreenState extends State<AdminRegistrationRequestsScreen> {
  final _api = AuthApi();
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = AuthSession.instance.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Not signed in.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _api.listPendingRegistrations(token: token);
      final list = res['pending'];
      final mapped = <Map<String, dynamic>>[];
      if (list is List) {
        for (final e in list) {
          if (e is Map<String, dynamic>) mapped.add(e);
        }
      }
      if (!mounted) return;
      setState(() {
        _rows = mapped;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _approve(Map<String, dynamic> row) async {
    final id = row['id'];
    if (id == null) return;
    final token = AuthSession.instance.token;
    if (token == null) return;
    try {
      await _api.approveRegistration(token: token, userId: '$id');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approved ${row['email']}')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _reject(Map<String, dynamic> row) async {
    final id = row['id'];
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject registration?'),
        content: Text('${row['email']} will not be able to sign in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final token = AuthSession.instance.token;
    if (token == null) return;
    try {
      await _api.rejectRegistration(token: token, userId: '$id');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejected ${row['email']}')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration requests'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
              onRefresh: _load,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Text(
                                _error!,
                                style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        )
                      : _rows.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 120),
                                Icon(Icons.inbox_outlined, size: 48),
                                SizedBox(height: AppSpacing.md),
                                Center(child: Text('No pending registrations.')),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              itemCount: _rows.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, i) {
                                final row = _rows[i];
                                final name = row['name']?.toString() ?? '';
                                final email = row['email']?.toString() ?? '';
                                final pilotId = row['pilot_id']?.toString();
                                final created = row['created_at']?.toString();
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 4),
                                        Text(email, style: TextStyle(color: scheme.onSurfaceVariant)),
                                        if (pilotId != null && pilotId.isNotEmpty)
                                          Text('Pilot ID: $pilotId', style: Theme.of(context).textTheme.bodySmall),
                                        if (created != null)
                                          Text('Requested: $created',
                                              style: Theme.of(context).textTheme.bodySmall),
                                        const SizedBox(height: AppSpacing.md),
                                        Row(
                                          children: [
                                            FilledButton.icon(
                                              onPressed: () => _approve(row),
                                              icon: const Icon(Icons.check_rounded, size: 18),
                                              label: const Text('Approve'),
                                            ),
                                            const SizedBox(width: AppSpacing.sm),
                                            OutlinedButton.icon(
                                              onPressed: () => _reject(row),
                                              icon: const Icon(Icons.close_rounded, size: 18),
                                              label: const Text('Reject'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
    );
  }
}
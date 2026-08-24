import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../shared/theme/digititan_theme.dart';

/// Ops Admin — pending reseller application detail + approve / reject.
class PendingResellerDetailScreen extends StatelessWidget {
  final AppContainer container;
  final PendingResellerApplication application;

  const PendingResellerDetailScreen({
    super.key,
    required this.container,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final p = application;
    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Text(
            'Pending application',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
          _Row(label: 'Name', value: p.name),
          _Row(label: 'Email', value: p.email),
          _Row(
            label: 'Academy / centre',
            value: p.academyName ?? 'Independent / programme support',
          ),
          _Row(
            label: 'Applied',
            value: p.appliedAt.toIso8601String().substring(0, 10),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'approve'),
            child: const Text('Approve & issue code'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, 'reject'),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

/// Ops Admin — approved (or deactivated) reseller profile detail.
class ResellerProfileDetailScreen extends StatefulWidget {
  final AppContainer container;
  final String email;

  const ResellerProfileDetailScreen({
    super.key,
    required this.container,
    required this.email,
  });

  @override
  State<ResellerProfileDetailScreen> createState() =>
      _ResellerProfileDetailScreenState();
}

class _ResellerProfileDetailScreenState extends State<ResellerProfileDetailScreen> {
  ResellerProfile? _profile;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await widget.container.adminRepository.getResellerProfiles();
    ResellerProfile? hit;
    for (final p in all) {
      if (p.email == widget.email) {
        hit = p;
        break;
      }
    }
    if (!mounted) return;
    setState(() => _profile = hit);
  }

  Future<void> _confirmDeactivate() async {
    final p = _profile;
    if (p == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Deactivate ${p.name}?'),
        content: Text(
          'They will be locked out of login and their code (${p.code}) will stop '
          'working until you unlock them or Digititan reactivates the account.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    await widget.container.adminRepository.deactivateReseller(p.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${p.name} deactivated — login locked')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _unlock() async {
    final p = _profile;
    if (p == null) return;
    setState(() => _busy = true);
    await widget.container.adminRepository.reactivateReseller(p.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${p.name} unlocked')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    if (p == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reseller')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Row(
            children: [
              Icon(
                p.isDeactivated ? Icons.lock_outline : Icons.storefront_outlined,
                color: p.isDeactivated ? Colors.redAccent : DigititanColors.teal,
              ),
              const SizedBox(width: 10),
              Text(
                p.status,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Row(label: 'Name', value: p.name),
          _Row(label: 'Email', value: p.email),
          _Row(label: 'Code', value: p.code),
          _Row(label: 'Type', value: p.codeType.label),
          _Row(
            label: 'Academy / centre',
            value: p.academyName ?? 'Independent',
          ),
          _Row(label: 'Total earned', value: 'R${p.totalEarned.toStringAsFixed(0)}'),
          _Row(label: 'Balance', value: 'R${p.balance.toStringAsFixed(0)}'),
          const SizedBox(height: 28),
          if (_busy)
            const Center(child: CircularProgressIndicator())
          else if (p.isDeactivated)
            FilledButton(onPressed: _unlock, child: const Text('Unlock account'))
          else if (p.isApproved)
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: _confirmDeactivate,
              child: const Text('Deactivate account'),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

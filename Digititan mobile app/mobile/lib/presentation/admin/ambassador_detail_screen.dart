import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';

/// Ops Admin — full ambassador profile + approve / reject / deactivate.
class AmbassadorDetailScreen extends StatefulWidget {
  final AppContainer container;
  final String applicationId;

  const AmbassadorDetailScreen({
    super.key,
    required this.container,
    required this.applicationId,
  });

  @override
  State<AmbassadorDetailScreen> createState() => _AmbassadorDetailScreenState();
}

class _AmbassadorDetailScreenState extends State<AmbassadorDetailScreen> {
  AmbassadorApplication? _app;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    AmbassadorApplication? hit;
    for (final a in DemoHub.instance.ambassadorApplications) {
      if (a.id == widget.applicationId) {
        hit = a;
        break;
      }
    }
    setState(() => _app = hit);
  }

  Future<void> _run(Future<void> Function() action, String okMessage) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(okMessage)));
      if (_app == null) {
        Navigator.pop(context, true);
        return;
      }
      // Pop after terminal actions so the list refreshes cleanly.
      if (_app!.status == 'approved' ||
          _app!.status == 'rejected' ||
          _app!.status == 'deactivated') {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDeactivate() async {
    final app = _app;
    if (app == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Deactivate ${app.name}?'),
        content: const Text(
          'They will be locked out of login until you unlock them '
          'or they contact Digititan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (ok != true) return;
    await _run(
      () => widget.container.adminRepository.deactivateAmbassador(app.id),
      '${app.name} deactivated — login locked',
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = _app;
    if (app == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ambassador')),
        body: const Center(child: Text('Ambassador not found')),
      );
    }

    final statusLabel = switch (app.status) {
      'approved' => 'Approved',
      'under_review' => 'Under review',
      'rejected' => 'Rejected',
      'deactivated' => 'Deactivated',
      _ => app.status,
    };

    return Scaffold(
      appBar: AppBar(title: Text(app.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Row(
            children: [
              Icon(
                app.isDeactivated
                    ? Icons.lock_outline
                    : app.isApproved
                        ? Icons.verified_outlined
                        : Icons.pending_outlined,
                color: app.isDeactivated
                    ? Colors.redAccent
                    : app.isApproved
                        ? DigititanColors.teal
                        : null,
              ),
              const SizedBox(width: 10),
              Text(
                statusLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(label: 'Name', value: app.name),
          _DetailRow(label: 'Email', value: app.email),
          _DetailRow(label: 'Phone', value: app.phone),
          _DetailRow(
            label: 'Applied',
            value: app.createdAt.toIso8601String().substring(0, 10),
          ),
          const SizedBox(height: 8),
          Text('Motivation', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(app.motivation, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 28),
          if (_busy)
            const Center(child: CircularProgressIndicator())
          else ...[
            if (app.isUnderReview) ...[
              FilledButton(
                onPressed: () => _run(
                  () => widget.container.adminRepository.approveAmbassador(app.id),
                  '${app.name} is now an official ambassador',
                ),
                child: const Text('Approve'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _run(
                  () => widget.container.adminRepository.rejectAmbassador(app.id),
                  '${app.name} rejected',
                ),
                child: const Text('Reject'),
              ),
            ],
            if (app.isApproved) ...[
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: _confirmDeactivate,
                child: const Text('Deactivate account'),
              ),
            ],
            if (app.isDeactivated) ...[
              FilledButton(
                onPressed: () => _run(
                  () => widget.container.adminRepository.reactivateAmbassador(app.id),
                  '${app.name} unlocked',
                ),
                child: const Text('Unlock account'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

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

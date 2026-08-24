import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';

/// Logged-in customer applies to become a reseller (Ops must approve + issue code).
class BecomeResellerScreen extends StatefulWidget {
  final AppContainer container;
  final User user;

  const BecomeResellerScreen({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  State<BecomeResellerScreen> createState() => _BecomeResellerScreenState();
}

class _BecomeResellerScreenState extends State<BecomeResellerScreen> {
  final _academy = TextEditingController();
  bool _loading = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _academy.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.container.resellerRepository.applyToBecomeReseller(
        name: widget.user.name,
        email: widget.user.email,
        academyName: _academy.text.trim().isEmpty ? null : _academy.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _submitted = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Reseller')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          const QuietNotice(
            message:
                'Ops Admin must approve your application and issue a VNA-B-* or '
                'VNA-C-* code before you can sell.',
          ),
          const SizedBox(height: 16),
          if (_submitted) ...[
            const Icon(Icons.check_circle_outline, color: DigititanColors.accent, size: 48),
            const SizedBox(height: 12),
            Text(
              'Application submitted',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your status is under review. Log in later as a reseller account '
              'once Ops approves you, or keep shopping as a customer.',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Profile'),
            ),
          ] else ...[
            Text(widget.user.name, style: Theme.of(context).textTheme.titleMedium),
            Text(widget.user.email, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            TextField(
              controller: _academy,
              decoration: const InputDecoration(
                labelText: 'Academy / centre (optional)',
                hintText: 'e.g. Lesedi Labatu Academy',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Submitting...' : 'Submit application'),
            ),
          ],
        ],
      ),
    );
  }
}

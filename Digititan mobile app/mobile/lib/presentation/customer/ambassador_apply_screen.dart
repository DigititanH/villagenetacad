import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';

class AmbassadorApplyScreen extends StatefulWidget {
  final User? user;

  const AmbassadorApplyScreen({super.key, this.user});

  @override
  State<AmbassadorApplyScreen> createState() => _AmbassadorApplyScreenState();
}

class _AmbassadorApplyScreenState extends State<AmbassadorApplyScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _phone = TextEditingController();
  final _motivation = TextEditingController();
  bool _loading = false;
  bool _submitted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user?.name ?? '');
    _email = TextEditingController(text: widget.user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _motivation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) {
      setState(() => _error = 'Name and email are required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _email.text.trim().toLowerCase();
    DemoHub.instance.ambassadorApplications.insert(
      0,
      AmbassadorApplication(
        id: 'amb-${DateTime.now().millisecondsSinceEpoch}',
        name: _name.text.trim(),
        email: email,
        phone: _phone.text.trim(),
        motivation: _motivation.text.trim(),
        createdAt: DateTime.now(),
      ),
    );
    DemoHub.instance.log('Ambassador application: $email');

    if (!mounted) return;
    setState(() {
      _loading = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lockedEmail = widget.user != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Become an Ambassador')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DigititanColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: DigititanColors.danger.withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'Never pay cash to individuals or ambassadors. '
              'All payments go through Digititan / Village NetAcad checkout only.',
              style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
            ),
          ),
          const SizedBox(height: 16),
          if (_submitted) ...[
            const Icon(Icons.hourglass_top, size: 40, color: DigititanColors.primary),
            const SizedBox(height: 12),
            Text(
              'Application under review',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ops Admin must approve ambassador applications. '
              'Until then you are not an official Village NetAcad ambassador. '
              'After approval, switch to Ambassador view from Profile.',
            ),
          ] else ...[
            TextField(
              controller: _name,
              readOnly: lockedEmail,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            TextField(
              controller: _email,
              readOnly: lockedEmail,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _motivation,
              decoration: const InputDecoration(
                labelText: 'Why do you want to be an ambassador?',
              ),
              maxLines: 4,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Submitting...' : 'Submit application'),
            ),
          ],
        ],
      ),
    );
  }
}

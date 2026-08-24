import 'package:flutter/material.dart';

import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';
import 'verify_reseller_screen.dart';

/// Local record until DemoHub.ambassadorApplications is wired by parent infra.
class _AmbassadorApplication {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String motivation;
  final DateTime createdAt;

  const _AmbassadorApplication({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.motivation,
    required this.createdAt,
  });
}

final List<_AmbassadorApplication> _fallbackApplications = [];

class AmbassadorApplyScreen extends StatefulWidget {
  const AmbassadorApplyScreen({super.key});

  @override
  State<AmbassadorApplyScreen> createState() => _AmbassadorApplyScreenState();
}

class _AmbassadorApplyScreenState extends State<AmbassadorApplyScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _motivation = TextEditingController();
  bool _loading = false;
  bool _submitted = false;
  String? _error;

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

    final application = _AmbassadorApplication(
      id: 'amb-${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      email: _email.text.trim().toLowerCase(),
      phone: _phone.text.trim(),
      motivation: _motivation.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      (DemoHub.instance as dynamic).ambassadorApplications.insert(0, application);
    } catch (_) {
      _fallbackApplications.insert(0, application);
    }

    DemoHub.instance.log('Ambassador application: ${application.email}');

    if (!mounted) return;
    setState(() {
      _loading = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply as ambassador')),
      body: Column(
        children: [
          const DemoBanner(message: 'Never pay cash to individuals or ambassadors'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_submitted) ...[
                  const Icon(Icons.hourglass_top, color: DigititanColors.primary, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Application under review',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thank you. Digititan Ops will review your ambassador application. '
                    'Never pay cash to individuals — only use official Digititan channels.',
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const VerifyResellerScreen(),
                        ),
                      );
                    },
                    child: const Text('Public verify — check reseller codes'),
                  ),
                ] else ...[
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  TextField(
                    controller: _email,
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
                  const SizedBox(height: 12),
                  QuietNotice(
                    message:
                        'Ambassador roles are reviewed by Digititan. '
                        'Use public verify to confirm legitimate reseller codes before paying.',
                    trailing: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VerifyResellerScreen(),
                          ),
                        );
                      },
                      child: const Text('Verify'),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: Text(_loading ? 'Submitting…' : 'Submit application'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

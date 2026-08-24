import 'package:flutter/material.dart';

import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';

class VerifyAmbassadorScreen extends StatefulWidget {
  const VerifyAmbassadorScreen({super.key});

  @override
  State<VerifyAmbassadorScreen> createState() => _VerifyAmbassadorScreenState();
}

class _VerifyAmbassadorScreenState extends State<VerifyAmbassadorScreen> {
  final _input = TextEditingController();
  AmbassadorApplication? _hit;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _lookup() {
    final q = _input.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _error = 'Enter ambassador email or id';
        _hit = null;
      });
      return;
    }
    AmbassadorApplication? found;
    for (final a in DemoHub.instance.ambassadorApplications) {
      if (a.email.toLowerCase() == q || a.id.toLowerCase() == q) {
        found = a;
        break;
      }
    }
    setState(() {
      _hit = found;
      _error = found == null ? 'No ambassador found for "$q"' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify ambassador')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DigititanColors.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DigititanColors.danger.withOpacity(0.4)),
            ),
            child: const Text(
              'Never pay cash to individuals or ambassadors.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _input,
            decoration: const InputDecoration(
              labelText: 'Email or ambassador id',
              hintText: 'lerato.ambassador@example.com',
            ),
            onSubmitted: (_) => _lookup(),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _lookup, child: const Text('Check')),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
          ],
          if (_hit != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hit!.status == 'approved'
                      ? DigititanColors.teal
                      : DigititanColors.accent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hit!.status == 'approved'
                        ? 'Approved ambassador'
                        : 'Under review',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _hit!.status == 'approved'
                          ? DigititanColors.teal
                          : DigititanColors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_hit!.name, style: Theme.of(context).textTheme.titleMedium),
                  Text(_hit!.email),
                  Text('Status: ${_hit!.status}'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

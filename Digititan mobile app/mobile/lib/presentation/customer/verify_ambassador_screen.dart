import 'package:flutter/material.dart';

import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';

class _DemoAmbassador {
  final String id;
  final String name;
  final String email;
  final String status;

  const _DemoAmbassador({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });
}

const _fallbackAmbassadors = [
  _DemoAmbassador(
    id: 'amb-1',
    name: 'Lerato Mokoena',
    email: 'lerato@example.com',
    status: 'approved',
  ),
  _DemoAmbassador(
    id: 'amb-2',
    name: 'Sipho Ndlovu',
    email: 'sipho@example.com',
    status: 'under_review',
  ),
];

List<_DemoAmbassador> _loadAmbassadors() {
  try {
    final raw = (DemoHub.instance as dynamic).ambassadors as List<dynamic>?;
    if (raw == null || raw.isEmpty) return _fallbackAmbassadors;
    return raw
        .map(
          (a) => _DemoAmbassador(
            id: '${a.id}',
            name: '${a.name}',
            email: '${a.email}'.toLowerCase(),
            status: '${a.status}',
          ),
        )
        .toList();
  } catch (_) {
    return _fallbackAmbassadors;
  }
}

class VerifyAmbassadorScreen extends StatefulWidget {
  const VerifyAmbassadorScreen({super.key});

  @override
  State<VerifyAmbassadorScreen> createState() => _VerifyAmbassadorScreenState();
}

class _VerifyAmbassadorScreenState extends State<VerifyAmbassadorScreen> {
  final _input = TextEditingController();
  _DemoAmbassador? _match;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _lookup() {
    final query = _input.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _match = null;
        _error = 'Enter an ambassador email or ID';
      });
      return;
    }

    final ambassadors = _loadAmbassadors();
    _DemoAmbassador? hit;
    for (final a in ambassadors) {
      if (a.email == query ||
          a.id.toLowerCase() == query ||
          a.name.toLowerCase().contains(query)) {
        hit = a;
        break;
      }
    }

    setState(() {
      _match = hit;
      _error = hit == null ? 'No ambassador found for "$query"' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final approved = _match?.status == 'approved';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify ambassador')),
      body: Column(
        children: [
          const DemoBanner(message: 'Never pay cash to individuals or ambassadors'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Confirm that someone claiming to be a Digititan ambassador '
                  'is registered before you engage or pay.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _input,
                  decoration: const InputDecoration(
                    labelText: 'Ambassador email or ID',
                    hintText: 'lerato@example.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => _lookup(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _lookup,
                  child: const Text('Look up'),
                ),
                if (_match != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                approved ? Icons.verified : Icons.hourglass_top,
                                color: approved
                                    ? DigititanColors.teal
                                    : DigititanColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                approved ? 'Approved ambassador' : 'Under review',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: approved
                                          ? DigititanColors.teal
                                          : DigititanColors.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_match!.name),
                          Text(_match!.email),
                          Text('ID: ${_match!.id}'),
                          const SizedBox(height: 8),
                          const Text(
                            'Digititan never asks for cash payments to individuals. '
                            'Use official store and verify links only.',
                          ),
                        ],
                      ),
                    ),
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

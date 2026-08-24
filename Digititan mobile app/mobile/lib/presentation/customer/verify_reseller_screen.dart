import 'package:flutter/material.dart';

import '../../domain/entities/reseller.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';

class VerifyResellerScreen extends StatefulWidget {
  const VerifyResellerScreen({super.key});

  @override
  State<VerifyResellerScreen> createState() => _VerifyResellerScreenState();
}

class _VerifyResellerScreenState extends State<VerifyResellerScreen> {
  final _input = TextEditingController();
  IssuedResellerCode? _issued;
  ResellerProfile? _profile;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  String _extractCode(String raw) {
    final trimmed = raw.trim();
    final uriMatch = RegExp(r'vna://verify/(.+)', caseSensitive: false).firstMatch(trimmed);
    if (uriMatch != null) return uriMatch.group(1)!.trim();
    return trimmed;
  }

  void _lookup() {
    setState(() {
      _error = null;
      _issued = null;
      _profile = null;
    });

    final code = _extractCode(_input.text).toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Enter a reseller code or verify link');
      return;
    }

    final issued = DemoHub.instance.findCode(code);
    if (issued == null) {
      setState(() => _error = 'Code not found or inactive');
      return;
    }

    final profile = DemoHub.instance.resellerProfiles[issued.resellerEmail.toLowerCase()];
    setState(() {
      _issued = issued;
      _profile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final approved = _profile?.isApproved == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify reseller code')),
      body: Column(
        children: [
          const DemoBanner(
            message: 'Public verify — never pay cash to individuals',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Check that a Village NetAcad reseller code is legitimate before you buy.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _input,
                  decoration: const InputDecoration(
                    labelText: 'Code or vna://verify/CODE',
                    hintText: 'VNA-B-LERATO',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => _lookup(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try: VNA-B-LERATO',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _lookup,
                  child: const Text('Verify code'),
                ),
                if (_issued != null) ...[
                  const SizedBox(height: 20),
                  _ResultCard(
                    approved: approved,
                    issued: _issued!,
                    profile: _profile,
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

class _ResultCard extends StatelessWidget {
  final bool approved;
  final IssuedResellerCode issued;
  final ResellerProfile? profile;

  const _ResultCard({
    required this.approved,
    required this.issued,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final color = approved ? DigititanColors.teal : DigititanColors.danger;
    final title = approved ? 'Verified reseller' : 'Not approved';
    final subtitle = approved
        ? '${issued.resellerName} is an approved ${issued.type.label} reseller.'
        : profile == null
            ? 'This code exists but has no active profile.'
            : '${issued.resellerName} is ${profile!.status} — not approved for sales.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  approved ? Icons.verified : Icons.warning_amber_rounded,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 12),
            Text('Code: ${issued.code}'),
            Text('Type: ${issued.type.label}'),
            if (issued.academyName != null) Text('Academy: ${issued.academyName}'),
            Text('Verify link: ${AppConfig.resellerVerifyPayload(issued.code)}'),
          ],
        ),
      ),
    );
  }
}

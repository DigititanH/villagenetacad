import 'package:flutter/material.dart';

import '../../domain/entities/reseller.dart';
import '../../domain/repositories/reseller_repository.dart';
import '../../infrastructure/api/api_client.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';

/// Public reseller-code check (meeting: customers verify before trusting a code).
///
/// Live: `GET /api/resellers/verify/{code}` via [ResellerRepository.verifyCode].
class VerifyResellerScreen extends StatefulWidget {
  final String? initialCode;
  final ResellerRepository resellerRepository;

  const VerifyResellerScreen({
    super.key,
    required this.resellerRepository,
    this.initialCode,
  });

  @override
  State<VerifyResellerScreen> createState() => _VerifyResellerScreenState();
}

class _VerifyResellerScreenState extends State<VerifyResellerScreen> {
  late final TextEditingController _input;
  IssuedResellerCode? _issued;
  ResellerProfile? _profile;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _input = TextEditingController(text: widget.initialCode ?? '');
    if (widget.initialCode != null && widget.initialCode!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookup());
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  String _extractCode(String raw) {
    final trimmed = raw.trim();
    final uriMatch =
        RegExp(r'vna://verify/(.+)', caseSensitive: false).firstMatch(trimmed);
    if (uriMatch != null) return uriMatch.group(1)!.trim();
    return trimmed;
  }

  Future<void> _lookup() async {
    setState(() {
      _error = null;
      _issued = null;
      _profile = null;
      _loading = true;
    });

    final code = _extractCode(_input.text).toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Enter a reseller code or verify link';
      });
      return;
    }

    try {
      final issued = await widget.resellerRepository.verifyCode(code);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _issued = issued;
        _profile = ResellerProfile(
          email: issued.resellerEmail.isEmpty
              ? 'verified@live'
              : issued.resellerEmail,
          name: issued.resellerName,
          code: issued.code,
          codeType: issued.type,
          status: issued.active ? 'approved' : 'pending',
          totalEarned: 0,
          balance: 0,
          amountDueToDigititan: 0,
          commissionRate: 0,
          academyName: issued.academyName,
        );
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
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
    final approved = _profile?.isApproved == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify reseller code')),
      body: Column(
        children: [
          DemoBanner(
            message: AppConfig.useLiveApi
                ? 'Live verify — never pay cash to individuals'
                : 'Demo verify — never pay cash to individuals',
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
                  onSubmitted: (_) => _loading ? null : _lookup(),
                ),
                if (!AppConfig.useLiveApi) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Try: VNA-B-LERATO',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!,
                      style: const TextStyle(color: DigititanColors.danger)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _lookup,
                  child: Text(_loading ? 'Checking...' : 'Verify code'),
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
        : '${issued.resellerName} is ${profile?.status ?? 'pending'} — not approved for sales.';

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
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 12),
            Text('Code: ${issued.code}'),
            Text('Type: ${issued.type.label}'),
            if (issued.academyName != null && issued.academyName!.isNotEmpty)
              Text('Academy: ${issued.academyName}'),
            Text('Verify link: ${AppConfig.resellerVerifyPayload(issued.code)}'),
          ],
        ),
      ),
    );
  }
}

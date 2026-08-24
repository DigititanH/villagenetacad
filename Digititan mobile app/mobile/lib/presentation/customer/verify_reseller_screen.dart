import 'package:flutter/material.dart';

import '../../domain/entities/reseller.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';

/// Buyer POV: confirm a reseller is legit (meeting feedback + Karabo QR idea).
class VerifyResellerScreen extends StatefulWidget {
  final String? initialCode;

  const VerifyResellerScreen({super.key, this.initialCode});

  @override
  State<VerifyResellerScreen> createState() => _VerifyResellerScreenState();
}

class _VerifyResellerScreenState extends State<VerifyResellerScreen> {
  late final TextEditingController _input;
  _VerifyResult? _result;

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
    var t = raw.trim();
    final uri = RegExp(r'vna://verify/([A-Za-z0-9\-]+)', caseSensitive: false)
        .firstMatch(t);
    if (uri != null) return uri.group(1)!.toUpperCase();
    t = t.replaceAll(RegExp(r'^vna://verify/', caseSensitive: false), '');
    return t.toUpperCase();
  }

  void _lookup() {
    final code = _extractCode(_input.text);
    if (code.isEmpty) {
      setState(() => _result = _VerifyResult.invalid('Enter a code or QR link'));
      return;
    }
    final issued = DemoHub.instance.findCode(code);
    if (issued == null) {
      setState(
        () => _result = _VerifyResult.invalid(
          'No reseller found for $code. Ask for an official Digititan code.',
        ),
      );
      return;
    }
    ResellerProfile? profile;
    for (final p in DemoHub.instance.resellerProfiles.values) {
      if (p.code.toUpperCase() == issued.code.toUpperCase()) {
        profile = p;
        break;
      }
    }
    final approved = issued.active && (profile == null || profile.isApproved);
    setState(() {
      _result = _VerifyResult.ok(
        code: issued.code,
        name: issued.resellerName,
        type: issued.type,
        status: approved ? 'Approved / active' : 'Inactive or pending',
        academyName: profile?.academyName,
        email: profile?.email,
        legit: approved,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify reseller')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Scan their QR or enter the referral code to check they are a '
            'legit Digititan / Village NetAcad reseller.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _input,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Code or QR link',
              hintText: 'VNA-B-LERATO or vna://verify/...',
            ),
            onSubmitted: (_) => _lookup(),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _lookup,
            child: const Text('Check reseller'),
          ),
          const SizedBox(height: 8),
          Text(
            'Live API: GET /api/resellers/verify/{code}\n'
            'Demo try: VNA-B-LERATO',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_result != null) ...[
            const SizedBox(height: 20),
            _result!.buildCard(context),
          ],
        ],
      ),
    );
  }
}

class _VerifyResult {
  final bool ok;
  final String? message;
  final String? code;
  final String? name;
  final ResellerCodeType? type;
  final String? status;
  final String? academyName;
  final String? email;
  final bool legit;

  _VerifyResult.invalid(this.message)
      : ok = false,
        code = null,
        name = null,
        type = null,
        status = null,
        academyName = null,
        email = null,
        legit = false;

  _VerifyResult.ok({
    required this.code,
    required this.name,
    required this.type,
    required this.status,
    required this.legit,
    this.academyName,
    this.email,
  })  : ok = true,
        message = null;

  Widget buildCard(BuildContext context) {
    if (!ok) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: DigititanColors.danger.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DigititanColors.danger.withOpacity(0.4)),
        ),
        child: Text(message ?? 'Not found'),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DigititanColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: legit ? DigititanColors.teal : DigititanColors.danger,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                legit ? Icons.verified : Icons.warning_amber,
                color: legit ? DigititanColors.teal : DigititanColors.danger,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  legit ? 'Verified reseller' : 'Not approved',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: legit ? DigititanColors.teal : DigititanColors.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(name!, style: Theme.of(context).textTheme.titleMedium),
          Text(code!, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(type!.label),
          Text(status!),
          if (academyName != null) Text('Academy: $academyName'),
          if (email != null)
            Text(email!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            AppConfig.resellerVerifyPayload(code!),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

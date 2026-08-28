import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../shared/config/app_config.dart';
import '../../shared/result/result.dart';
import 'otp_screen.dart';
import 'reseller_pending_approval_screen.dart';

/// Reseller registration path (meeting / locked model).
enum _ResellerKind {
  /// VNA-B · 53% · rest Digititan (no centre affiliation).
  independent,

  /// VNA-B · 53% · centre 26% · Digititan 21%.
  affiliated,

  /// VNA-C · 26% · rest Digititan.
  centre,
}

class RegisterScreen extends StatefulWidget {
  final AppContainer container;

  const RegisterScreen({super.key, required this.container});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _academy = TextEditingController();
  UserRole _role = UserRole.customer;
  _ResellerKind _resellerKind = _ResellerKind.independent;
  bool _loading = false;
  String? _error;

  bool _isPendingApprovalMessage(String message) {
    final m = message.toLowerCase();
    return m.contains('admin must approve') ||
        m.contains('pending admin approval') ||
        m.contains('pending until');
  }

  String get _resellerKindApi {
    switch (_resellerKind) {
      case _ResellerKind.independent:
        return 'independent';
      case _ResellerKind.affiliated:
        return 'affiliated';
      case _ResellerKind.centre:
        return 'centre';
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await widget.container.registerWithEmail(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      role: _role,
      academyName: _role == UserRole.reseller ? _academy.text : null,
      resellerKind: _role == UserRole.reseller ? _resellerKindApi : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success(:final data):
        if (AppConfig.useLiveApi) {
          await _showLiveRegisterDone(data);
          if (!mounted) return;
          Navigator.of(context).pop(data);
          return;
        }
        final verified = await Navigator.of(context).push<User>(
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              container: widget.container,
              email: data.email,
            ),
          ),
        );
        if (verified != null && mounted) {
          Navigator.of(context).pop(verified);
        }
      case Failure(:final message):
        if (_isPendingApprovalMessage(message)) {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => ResellerPendingApprovalScreen(
                email: _email.text.trim().toLowerCase(),
              ),
            ),
          );
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          setState(() => _error = message);
        }
    }
  }

  Future<void> _showLiveRegisterDone(User user) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Account created'),
        content: Text(
          'You are signed in on the app as ${user.email}.\n\n'
          'We sent a welcome email from app@villagenetacad.co.za '
          '(no confirm link needed).\n\n'
          'Use the same email and password on villagenetacad.co.za.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _academy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needAcademy = _role == UserRole.reseller &&
        (_resellerKind == _ResellerKind.affiliated ||
            _resellerKind == _ResellerKind.centre);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password (min 6 characters)',
              ),
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 8),
            const Text('Register as'),
            DropdownButton<UserRole>(
              value: _role,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: UserRole.customer,
                  child: Text('Customer'),
                ),
                DropdownMenuItem(
                  value: UserRole.reseller,
                  child: Text('Reseller'),
                ),
              ],
              onChanged: (v) => setState(() {
                _role = v ?? UserRole.customer;
                if (_role != UserRole.reseller) {
                  _resellerKind = _ResellerKind.independent;
                }
              }),
            ),
            if (_role == UserRole.reseller) ...[
              const SizedBox(height: 12),
              Text(
                'Reseller path',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Difference is the code: VNA-B (person, 53%) vs VNA-C (centre, 26%).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              RadioListTile<_ResellerKind>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Independent (support Digititan)'),
                subtitle: const Text('VNA-B · you 53% · rest Digititan'),
                value: _ResellerKind.independent,
                groupValue: _resellerKind,
                onChanged: (v) => setState(() {
                  _resellerKind = v ?? _ResellerKind.independent;
                  if (_resellerKind == _ResellerKind.independent) {
                    _academy.clear();
                  }
                }),
              ),
              RadioListTile<_ResellerKind>(
                contentPadding: EdgeInsets.zero,
                title: const Text('Affiliated with a centre'),
                subtitle: const Text(
                  'VNA-B · you 53% · centre 26% · Digititan 21%',
                ),
                value: _ResellerKind.affiliated,
                groupValue: _resellerKind,
                onChanged: (v) =>
                    setState(() => _resellerKind = v ?? _ResellerKind.affiliated),
              ),
              RadioListTile<_ResellerKind>(
                contentPadding: EdgeInsets.zero,
                title: const Text('I am registering as a centre'),
                subtitle: const Text('VNA-C · centre 26% · rest Digititan'),
                value: _ResellerKind.centre,
                groupValue: _resellerKind,
                onChanged: (v) =>
                    setState(() => _resellerKind = v ?? _ResellerKind.centre),
              ),
              if (needAcademy) ...[
                const SizedBox(height: 4),
                TextField(
                  controller: _academy,
                  decoration: InputDecoration(
                    labelText: _resellerKind == _ResellerKind.centre
                        ? 'Centre / academy name (required)'
                        : 'Centre you are affiliated with (required)',
                    hintText: 'e.g. Lesedi Labatu Academy',
                  ),
                ),
              ],
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(
                _loading
                    ? 'Creating...'
                    : _role == UserRole.reseller
                        ? 'Apply as reseller'
                        : 'Create account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

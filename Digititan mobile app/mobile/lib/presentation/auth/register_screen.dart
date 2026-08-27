import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../shared/config/app_config.dart';
import '../../shared/result/result.dart';
import 'otp_screen.dart';
import 'reseller_pending_approval_screen.dart';

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
  bool _loading = false;
  String? _error;

  bool _isPendingApprovalMessage(String message) {
    final m = message.toLowerCase();
    return m.contains('admin must approve') ||
        m.contains('pending admin approval') ||
        m.contains('pending until');
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
            // Leave register entirely — back on sign-in.
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
          'This is the same account as the website — you can open '
          'villagenetacad.co.za and sign in with the same email and password.\n\n'
          'Check your inbox for the website email-verification link '
          '(same flow as registering on the site).',
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
    final live = AppConfig.useLiveApi;
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
              onChanged: (v) => setState(() => _role = v ?? UserRole.customer),
            ),
            if (_role == UserRole.reseller) ...[
              const SizedBox(height: 8),
              Text(
                live
                    ? 'Reseller type (live): Ops later issues VNA-B (person, 53%) or '
                        'VNA-C (centre org, 26%). Typing a centre name does NOT make '
                        'you that centre — it only notes where you sell from. '
                        'Leave blank if you sell independently.'
                    : 'Optional linked academy / centre for your application.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _academy,
                decoration: const InputDecoration(
                  labelText: 'Academy / centre (optional)',
                  hintText: 'Leave blank if independent, or type linked centre name',
                ),
              ),
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

import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../shared/config/app_config.dart';
import '../../shared/result/result.dart';
import 'otp_screen.dart';

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
        setState(() => _error = message);
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
            if (live)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Creates a real Village NetAcad account (same database as '
                  'the website). After this, that email/password works on '
                  'villagenetacad.co.za too.\n\nAPI: ${AppConfig.apiBaseUrl}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
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
                  child: Text('Reseller (needs Admin approval)'),
                ),
              ],
              onChanged: (v) => setState(() => _role = v ?? UserRole.customer),
            ),
            if (_role == UserRole.reseller) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _academy,
                decoration: InputDecoration(
                  labelText: live
                      ? 'Academy / centre (required)'
                      : 'Academy / centre (optional)',
                  hintText: 'e.g. Lesedi Labatu Academy',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                live
                    ? 'Reseller accounts stay pending until an admin approves '
                        '(same as the website). You cannot sign in until then.'
                    : 'Reseller journey: Apply → Ops Admin approves → you receive a code.',
                style: const TextStyle(fontSize: 12),
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
            Text(
              live
                  ? '\nCustomer: signed in immediately; same login on the website.\n'
                      'Reseller: wait for admin approval, then sign in on app or site.'
                  : '\nAfter create, OTP email is printed in the flutter run console.\n'
                      'Prototype OTP = 123456',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

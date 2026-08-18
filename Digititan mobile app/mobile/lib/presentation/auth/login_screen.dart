import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../shared/config/app_config.dart';
import '../../shared/result/result.dart';
import '../../shared/widgets/demo_banner.dart';
import 'register_screen.dart';

/// Plain Auth UI (no branding polish yet).
/// Talks to use-cases only.
class LoginScreen extends StatefulWidget {
  final AppContainer container;
  final ValueChanged<User> onLoggedIn;

  const LoginScreen({
    super.key,
    required this.container,
    required this.onLoggedIn,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'customer@demo.com');
  final _password = TextEditingController(text: 'demo123');
  bool _loading = false;
  String? _error;

  Future<void> _signInEmail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.container.signInWithEmail(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success(:final data):
        widget.onLoggedIn(data);
      case Failure(:final message):
        setState(() => _error = message);
    }
  }

  /// One-tap role switch for stakeholder demos.
  Future<void> _signInAs(String email, String password) async {
    _email.text = email;
    _password.text = password;
    await _signInEmail();
  }

  Future<void> _signInGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.container.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success(:final data):
        widget.onLoggedIn(data);
      case Failure(:final message):
        setState(() => _error = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digititan Login')),
      body: Column(
        children: [
          const DemoBanner(message: AppConfig.demoModeLine),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    'OTPs for this demo\n'
                    '• Email verify: ${AppConfig.emailOtpDemo}\n'
                    '• Payment: ${AppConfig.paymentOtpDemo}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text('Quick sign-in (demo)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () => _signInAs('customer@demo.com', 'demo123'),
                    child: const Text('Sign in as Customer'),
                  ),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () => _signInAs('reseller@demo.com', 'demo123'),
                    child: const Text('Sign in as Reseller'),
                  ),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () => _signInAs('admin@demo.com', 'demo123'),
                    child: const Text('Sign in as Admin'),
                  ),
                  const SizedBox(height: 20),
                  Text('Or enter credentials', style: Theme.of(context).textTheme.titleSmall),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _signInEmail,
                    child: Text(_loading ? 'Please wait...' : 'Sign in with Email'),
                  ),
                  OutlinedButton(
                    onPressed: _loading ? null : _signInGoogle,
                    child: const Text('Sign in with Google (prototype stub)'),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            final user = await Navigator.of(context).push<User>(
                              MaterialPageRoute(
                                builder: (_) =>
                                    RegisterScreen(container: widget.container),
                              ),
                            );
                            if (user != null) widget.onLoggedIn(user);
                          },
                    child: const Text('Create account'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Google is stubbed until Firebase is connected.\n'
                    'Register OTP is printed in the flutter console.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

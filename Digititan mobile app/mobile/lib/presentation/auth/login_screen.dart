import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../shared/config/app_config.dart';
import '../../shared/result/result.dart';
import '../../shared/theme/digititan_brand_header.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';
import 'register_screen.dart';

/// Branded Auth UI — talks to use-cases only.
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
      body: Column(
        children: [
          const DemoBanner(message: AppConfig.demoModeLine),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F1FA),
                    DigititanColors.background,
                    Color(0xFFEAF7F0),
                  ],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                children: [
                  const DigititanBrandHeader(
                    tagline: "Building Africa's Technological Tomorrow",
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'OTPs for this demo\n'
                    '• Email verify: ${AppConfig.emailOtpDemo}\n'
                    '• Payment: ${AppConfig.paymentOtpDemo}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  Text('Quick sign-in (demo)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () => _signInAs('customer@demo.com', 'demo123'),
                    child: const Text('Sign in as Customer'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DigititanColors.accent,
                    ),
                    onPressed: _loading
                        ? null
                        : () => _signInAs('reseller@demo.com', 'demo123'),
                    child: const Text('Sign in as Reseller'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DigititanColors.primary,
                    ),
                    onPressed: _loading
                        ? null
                        : () => _signInAs('ops@demo.com', 'demo123'),
                    child: const Text('Sign in as Ops Admin'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DigititanColors.primaryDark,
                    ),
                    onPressed: _loading
                        ? null
                        : () => _signInAs('super@demo.com', 'demo123'),
                    child: const Text('Sign in as Super Admin'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Demo tip: Customer checkout with code VNA-B-LERATO → see Reseller Sales update.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 22),
                  Text('Or enter credentials', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _signInEmail,
                    child: Text(_loading ? 'Please wait...' : 'Sign in with Email'),
                  ),
                  const SizedBox(height: 8),
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

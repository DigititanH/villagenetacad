import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../shared/result/result.dart';
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
    setState(() => _loading = false);

    switch (result) {
      case Success(:final data):
        widget.onLoggedIn(data);
      case Failure(:final message):
        setState(() => _error = message);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.container.signInWithGoogle();
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Digititan prototype (core flows, branding later)\n'
              'OTPs: email 123456 · payment 654321',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _email.text = 'customer@demo.com';
                            _password.text = 'demo123';
                          });
                        },
                  child: const Text('Fill Customer'),
                ),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _email.text = 'reseller@demo.com';
                            _password.text = 'demo123';
                          });
                        },
                  child: const Text('Fill Reseller'),
                ),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _email.text = 'admin@demo.com';
                            _password.text = 'demo123';
                          });
                        },
                  child: const Text('Fill Admin'),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                          builder: (_) => RegisterScreen(container: widget.container),
                        ),
                      );
                      if (user != null) widget.onLoggedIn(user);
                    },
              child: const Text('Create account'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Google is stubbed until Firebase is connected.\n'
              'Register OTP is printed in flutter console (123456).',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

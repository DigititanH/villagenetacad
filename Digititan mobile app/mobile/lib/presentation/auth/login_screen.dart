import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../shared/config/app_config.dart';
import '../../shared/result/result.dart';
import '../../shared/theme/digititan_brand_header.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';
import 'account_deactivated_screen.dart';
import 'register_screen.dart';

/// Branded Auth UI — presentation-first layout for stakeholder demos.
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
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  bool _isDeactivatedMessage(String message) =>
      message.toLowerCase().contains('deactivated');

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
        if (_isDeactivatedMessage(message)) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AccountDeactivatedScreen(
                email: _email.text.trim().toLowerCase(),
              ),
            ),
          );
        } else {
          setState(() => _error = message);
        }
    }
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
          DemoBanner(message: AppConfig.demoModeLine),
          Expanded(
            child: BrandBackdrop(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                children: [
                  const DigititanBrandHeader(hero: true),
                  const SizedBox(height: 20),
                  Text(
                    'Sign in',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _loading ? null : _signInEmail(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(color: DigititanColors.danger),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _signInEmail,
                    child: Text(_loading ? 'Please wait...' : 'Sign in'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _loading ? null : _signInGoogle,
                    child: const Text('Google (stub)'),
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
                    child: const Text('Create account / apply as reseller'),
                  ),
                  const SizedBox(height: 8),
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        'Demo login details',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      childrenPadding: const EdgeInsets.only(bottom: 8),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password for all accounts: demo123\n\n'
                            'Customer:  customer@demo.com\n'
                            'Reseller:  reseller@demo.com\n'
                            'Ops Admin: ops@demo.com\n'
                            'Super Admin: super@demo.com\n\n'
                            'Email OTP: ${AppConfig.emailOtpDemo}\n'
                            'Payment OTP: ${AppConfig.paymentOtpDemo}\n'
                            'Fast sale code: VNA-B-LERATO',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
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

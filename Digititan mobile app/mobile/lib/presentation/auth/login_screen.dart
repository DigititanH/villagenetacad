import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../shared/config/app_config.dart';
import '../../shared/result/result.dart';
import '../../shared/theme/digititan_brand_header.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';
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
  bool _showCredentials = false;
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
            child: BrandBackdrop(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                children: [
                  const DigititanBrandHeader(),
                  const SizedBox(height: 28),
                  Text(
                    'Sign in',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose a role for the walkthrough',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  _RoleButton(
                    label: 'Customer',
                    subtitle: 'Training · Academies · Store',
                    color: DigititanColors.primary,
                    loading: _loading,
                    onTap: () => _signInAs('customer@demo.com', 'demo123'),
                  ),
                  _RoleButton(
                    label: 'Reseller',
                    subtitle: 'Clients · sales · month-end withdraw',
                    color: DigititanColors.accent,
                    loading: _loading,
                    onTap: () => _signInAs('reseller@demo.com', 'demo123'),
                  ),
                  _RoleButton(
                    label: 'Ops Admin',
                    subtitle: 'Orders · products · approve resellers',
                    color: DigititanColors.primary,
                    loading: _loading,
                    onTap: () => _signInAs('ops@demo.com', 'demo123'),
                  ),
                  _RoleButton(
                    label: 'Super Admin',
                    subtitle: 'Oversight · payout approvals',
                    color: DigititanColors.primaryDark,
                    loading: _loading,
                    onTap: () => _signInAs('super@demo.com', 'demo123'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(color: DigititanColors.danger),
                    ),
                  ],
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() => _showCredentials = !_showCredentials),
                    child: Text(
                      _showCredentials ? 'Hide email sign-in' : 'Sign in with email',
                    ),
                  ),
                  if (_showCredentials) ...[
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
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loading ? null : _signInEmail,
                      child: Text(_loading ? 'Please wait...' : 'Continue'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _loading ? null : _signInGoogle,
                      child: const Text('Google (stub)'),
                    ),
                  ],
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
                  const SizedBox(height: 12),
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        'Demo notes',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      childrenPadding: const EdgeInsets.only(bottom: 8),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email OTP: ${AppConfig.emailOtpDemo}\n'
                            'Payment OTP: ${AppConfig.paymentOtpDemo}\n'
                            'Password: demo123\n'
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

class _RoleButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

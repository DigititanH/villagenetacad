import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
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

    setState(() => _loading = false);

    switch (result) {
      case Success(:final data):
        if (!mounted) return;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
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
                  child: Text('Reseller (apply — needs Admin approval)'),
                ),
              ],
              onChanged: (v) => setState(() => _role = v ?? UserRole.customer),
            ),
            if (_role == UserRole.reseller) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _academy,
                decoration: const InputDecoration(
                  labelText: 'Academy / centre (optional)',
                  hintText: 'e.g. Lesedi Labatu Academy',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reseller journey: Apply → Ops Admin approves → you receive a '
                'Centre (VNA-C-*) or Beneficiary (VNA-B-*) code → then you can '
                'manage clients and earn from sales with that code.',
                style: TextStyle(fontSize: 12),
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
            const Text(
              '\nAfter create, OTP email is printed in the flutter run console.\n'
              'Prototype OTP = 123456',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

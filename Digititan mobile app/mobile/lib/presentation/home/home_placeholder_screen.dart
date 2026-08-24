import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';

/// Temporary landing page after login.
/// Real Home / Training / Academies / Store comes in later sprints.
class HomePlaceholderScreen extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const HomePlaceholderScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digititan Home (placeholder)'),
        actions: [
          TextButton(
            onPressed: onLogout,
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Logged in as:\n'
          'Name: ${user.name}\n'
          'Email: ${user.email}\n'
          'Role: ${user.role.name}\n'
          'Verified: ${user.emailVerified}\n\n'
          'Next sprints: Home content, Training, Academies, Store, Reseller, Admin.',
        ),
      ),
    );
  }
}

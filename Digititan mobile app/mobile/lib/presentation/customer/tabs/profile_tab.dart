import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/user.dart';
import '../my_orders_screen.dart';

class ProfileTab extends StatelessWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.container,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(user.name, style: Theme.of(context).textTheme.titleLarge),
            Text(user.email),
            Text('Role: ${user.role.name}'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MyOrdersScreen(
                      container: container,
                      user: user,
                    ),
                  ),
                );
              },
              child: const Text('My orders'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onLogout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

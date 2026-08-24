import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';

class NotificationsScreen extends StatefulWidget {
  final User user;

  const NotificationsScreen({super.key, required this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<DemoNotification> get _items {
    final key = widget.user.email.toLowerCase();
    return DemoHub.instance.notifications
        .where(
          (n) =>
              n.recipientEmail == null ||
              n.recipientEmail!.toLowerCase() == key,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: items.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = items[i];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: DigititanColors.muted),
                  ),
                  tileColor: n.read
                      ? null
                      : DigititanColors.teal.withOpacity(0.08),
                  leading: Icon(
                    n.read ? Icons.notifications_none : Icons.notifications_active,
                    color: DigititanColors.primary,
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.read ? FontWeight.w500 : FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(n.body),
                  onTap: () {
                    setState(() => n.read = true);
                  },
                );
              },
            ),
    );
  }
}

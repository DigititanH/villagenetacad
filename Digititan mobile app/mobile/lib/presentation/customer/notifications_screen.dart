import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';

class _DemoNotification {
  final String id;
  final String title;
  final String body;
  final String? recipientEmail;
  bool read;
  final DateTime createdAt;

  _DemoNotification({
    required this.id,
    required this.title,
    required this.body,
    this.recipientEmail,
    this.read = false,
    required this.createdAt,
  });
}

List<_DemoNotification> _seedNotifications() => [
      _DemoNotification(
        id: 'n-1',
        title: 'Order update',
        body: 'Your order ORD-DEMO-1001 is being processed at Digititan Store.',
        recipientEmail: 'aisha@example.com',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      _DemoNotification(
        id: 'n-2',
        title: 'Training intake open',
        body: 'Lesedi Labatu Academy registration opens 1 Sep 2026.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _DemoNotification(
        id: 'n-3',
        title: 'Reseller verify reminder',
        body: 'Always verify VNA codes before paying — use public verify in the app.',
        recipientEmail: 'aisha@example.com',
        read: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

List<_DemoNotification> _loadNotifications() {
  try {
    final raw = (DemoHub.instance as dynamic).notifications as List<dynamic>?;
    if (raw == null) return _seedNotifications();
    return raw
        .map(
          (n) => _DemoNotification(
            id: '${n.id}',
            title: '${n.title}',
            body: '${n.body}',
            recipientEmail: n.recipientEmail as String?,
            read: n.read == true,
            createdAt: n.createdAt is DateTime
                ? n.createdAt as DateTime
                : DateTime.now(),
          ),
        )
        .toList();
  } catch (_) {
    return _seedNotifications();
  }
}

class NotificationsScreen extends StatefulWidget {
  final User? user;

  const NotificationsScreen({super.key, this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<_DemoNotification> _items;

  @override
  void initState() {
    super.initState();
    _items = _filtered(_loadNotifications());
  }

  List<_DemoNotification> _filtered(List<_DemoNotification> all) {
    final email = widget.user?.email.toLowerCase();
    if (email == null) return all;
    return all
        .where((n) => n.recipientEmail == null || n.recipientEmail == email)
        .toList();
  }

  void _markRead(_DemoNotification item) {
    setState(() => item.read = true);
    try {
      final hub = DemoHub.instance as dynamic;
      final raw = hub.notifications as List<dynamic>?;
      final match = raw?.cast<dynamic>().firstWhere(
            (n) => '${n.id}' == item.id,
            orElse: () => null,
          );
      if (match != null) match.read = true;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _items.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = _items[i];
                return ListTile(
                  leading: Icon(
                    n.read ? Icons.notifications_none : Icons.notifications_active,
                    color: n.read ? DigititanColors.muted : DigititanColors.primary,
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(n.body),
                  trailing: n.read
                      ? null
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: DigititanColors.teal,
                            shape: BoxShape.circle,
                          ),
                        ),
                  onTap: () => _markRead(n),
                );
              },
            ),
    );
  }
}

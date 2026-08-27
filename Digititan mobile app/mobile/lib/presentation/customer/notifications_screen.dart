import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/user.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';

/// In-app notification inbox only — no email / SMTP.
class NotificationsScreen extends StatefulWidget {
  final User user;
  final AppContainer? container;

  const NotificationsScreen({
    super.key,
    required this.user,
    this.container,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (AppConfig.useLiveApi && widget.container?.apiClient != null) {
        final list = await widget.container!.apiClient!.getList(
          '/api/notifications',
          auth: true,
        );
        _items = list.whereType<Map>().map((raw) {
          final m = Map<String, dynamic>.from(raw);
          final read = m['is_read'] == true ||
              m['is_read'] == 1 ||
              m['is_read']?.toString() == '1';
          return AppNotification(
            id: m['id']?.toString() ?? '',
            title: m['title']?.toString() ?? 'Notice',
            body: m['message']?.toString() ?? m['body']?.toString() ?? '',
            type: m['type']?.toString() ?? 'info',
            createdAt:
                DateTime.tryParse(m['created_at']?.toString() ?? '') ??
                    DateTime.now(),
            read: read,
          );
        }).toList();
      } else {
        final key = widget.user.email.toLowerCase();
        _items = DemoHub.instance.notifications
            .where(
              (n) =>
                  n.recipientEmail == null ||
                  n.recipientEmail!.toLowerCase() == key,
            )
            .map(
              (n) => AppNotification(
                id: n.id,
                title: n.title,
                body: n.body,
                type: 'info',
                createdAt: n.createdAt,
                read: n.read,
              ),
            )
            .toList();
      }
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markRead(AppNotification n) async {
    if (n.read) return;
    setState(() => n.read = true);
    if (!AppConfig.useLiveApi || widget.container?.apiClient == null) {
      for (final d in DemoHub.instance.notifications) {
        if (d.id == n.id) d.read = true;
      }
      return;
    }
    try {
      await widget.container!.apiClient!.putJson(
        '/api/notifications/${n.id}/read',
        const {},
        auth: true,
      );
    } catch (_) {
      // Keep local read state; list still usable offline-ish.
    }
  }

  Future<void> _markAllRead() async {
    if (AppConfig.useLiveApi && widget.container?.apiClient != null) {
      try {
        await widget.container!.apiClient!.putJson(
          '/api/notifications/read-all',
          const {},
          auth: true,
        );
      } catch (_) {}
    } else {
      for (final d in DemoHub.instance.notifications) {
        d.read = true;
      }
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_items.any((n) => !n.read))
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          AppConfig.useLiveApi
                              ? 'No in-app notifications yet.\n'
                                  '(These stay inside the app — we are not sending Gmail until SMTP works.)'
                              : 'No notifications yet',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final n = _items[i];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: DigititanColors.muted),
                          ),
                          tileColor: n.read
                              ? null
                              : DigititanColors.teal.withOpacity(0.08),
                          leading: Icon(
                            n.read
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: DigititanColors.primary,
                          ),
                          title: Text(
                            n.title,
                            style: TextStyle(
                              fontWeight:
                                  n.read ? FontWeight.w500 : FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(n.body),
                          onTap: () => _markRead(n),
                        );
                      },
                    ),
    );
  }
}

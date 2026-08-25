import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/injection.dart';
import 'domain/entities/user.dart';
import 'shared/config/app_config.dart';

/// Entry point.
/// 1) Build DI container (wire concrete implementations)
/// 2) Restore JWT session when live API is enabled
/// 3) Start app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Visible in `adb logcat` even when Flutter tool loses VM service.
  debugPrint(
    AppConfig.useLiveApi
        ? 'VNA: live API -> ${AppConfig.apiBaseUrl}'
        : 'VNA: dummy auth (no API_BASE_URL)',
  );

  final container = AppContainer();
  User? initialUser;
  try {
    initialUser = await container.authRepository.getCurrentUser();
  } catch (e, st) {
    // Backend down / secure-storage glitch must not block first paint.
    debugPrint('VNA: session restore skipped: $e');
    debugPrint('$st');
  }
  runApp(DigititanApp(container: container, initialUser: initialUser));
}

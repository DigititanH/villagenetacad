import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/injection.dart';

/// Entry point.
/// 1) Build DI container (wire concrete implementations)
/// 2) Restore JWT session when live API is enabled
/// 3) Start app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = AppContainer();
  final initialUser = await container.authRepository.getCurrentUser();
  runApp(DigititanApp(container: container, initialUser: initialUser));
}

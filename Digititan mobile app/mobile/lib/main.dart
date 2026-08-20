import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/injection.dart';

/// Entry point.
/// 1) Build DI container (wire concrete implementations)
/// 2) Start app
/// No business logic here.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final container = AppContainer();
  runApp(DigititanApp(container: container));
}

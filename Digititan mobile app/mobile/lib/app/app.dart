import 'package:flutter/material.dart';

import '../domain/entities/user.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/shell/role_router.dart';
import '../shared/theme/digititan_theme.dart';
import 'injection.dart';

/// App shell with Village NetAcad brand theme.
class DigititanApp extends StatefulWidget {
  final AppContainer container;

  const DigititanApp({super.key, required this.container});

  @override
  State<DigititanApp> createState() => _DigititanAppState();
}

class _DigititanAppState extends State<DigititanApp> {
  User? _user;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Village NetAcad',
      debugShowCheckedModeBanner: false,
      theme: DigititanTheme.light(),
      home: _user == null
          ? LoginScreen(
              container: widget.container,
              onLoggedIn: (user) => setState(() => _user = user),
            )
          : RoleRouter(
              container: widget.container,
              user: _user!,
              onLogout: () async {
                await widget.container.authRepository.signOut();
                setState(() => _user = null);
              },
              onDemoUserSwitched: (user) => setState(() => _user = user),
            ),
    );
  }
}

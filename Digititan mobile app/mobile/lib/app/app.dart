import 'package:flutter/material.dart';

import '../domain/entities/user.dart';
import '../domain/enums/user_role.dart';
import '../infrastructure/dummy/demo_hub.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/shell/role_router.dart';
import '../shared/theme/digititan_theme.dart';
import 'injection.dart';

/// App shell with Village NetAcad brand theme.
class DigititanApp extends StatefulWidget {
  final AppContainer container;
  final User? initialUser;

  const DigititanApp({
    super.key,
    required this.container,
    this.initialUser,
  });

  @override
  State<DigititanApp> createState() => _DigititanAppState();
}

class _DigititanAppState extends State<DigititanApp> {
  User? _user;
  AppHat _hat = AppHat.customer;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialUser;
    if (initial != null) {
      _user = initial;
      _hat = _defaultHatFor(initial);
    }
  }

  AppHat _defaultHatFor(User user) {
    if (user.role == UserRole.reseller) return AppHat.reseller;
    if (user.role == UserRole.ambassador) return AppHat.ambassador;
    return AppHat.customer;
  }

  void _setSession(User user, {AppHat? hat}) {
    setState(() {
      _user = user;
      _hat = hat ?? _defaultHatFor(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Village NetAcad',
      debugShowCheckedModeBanner: false,
      theme: DigititanTheme.light(),
      home: _user == null
          ? LoginScreen(
              container: widget.container,
              onLoggedIn: (user) => _setSession(user),
            )
          : RoleRouter(
              container: widget.container,
              user: _user!,
              activeHat: _hat,
              onLogout: () async {
                await widget.container.authRepository.signOut();
                setState(() {
                  _user = null;
                  _hat = AppHat.customer;
                });
              },
              onSwitchHat: (hat) {
                final email = _user!.email;
                if (hat == AppHat.reseller &&
                    !DemoHub.instance.isApprovedReseller(email)) {
                  return;
                }
                if (hat == AppHat.ambassador &&
                    !DemoHub.instance.isApprovedAmbassador(email)) {
                  return;
                }
                setState(() => _hat = hat);
              },
              onDemoUserSwitched: (user) => _setSession(user),
            ),
    );
  }
}

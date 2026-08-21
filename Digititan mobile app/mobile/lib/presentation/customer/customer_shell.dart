import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import 'tabs/academies_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/store_tab.dart';
import 'tabs/training_tab.dart';

/// Customer shell = bottom navigation for the 3 pillars + home/profile.
class CustomerShell extends StatefulWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onLogout;

  const CustomerShell({
    super.key,
    required this.container,
    required this.user,
    required this.onLogout,
  });

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  void _goTraining() => setState(() => _index = 1);
  void _goStore() => setState(() => _index = 3);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
        container: widget.container,
        user: widget.user,
        onOpenTraining: _goTraining,
        onOpenStore: _goStore,
      ),
      TrainingTab(container: widget.container, user: widget.user),
      AcademiesTab(container: widget.container, user: widget.user),
      StoreTab(container: widget.container, user: widget.user),
      ProfileTab(
        container: widget.container,
        user: widget.user,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Training'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Academies'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Store'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

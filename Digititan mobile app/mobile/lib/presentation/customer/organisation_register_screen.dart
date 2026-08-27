import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../shared/config/app_config.dart';
import '../../shared/utils/open_digititan_store.dart';

/// ASC academy registration — same Microsoft Form as villagenetacad.co.za.
///
/// Wave 1 previously used a short in-app form (dummy lead). Leadership wants
/// parity with the website ASC Registration Form, so we open that form in the
/// system browser instead of collecting a subset of fields in the app.
class OrganisationRegisterScreen extends StatelessWidget {
  final AppContainer container;

  const OrganisationRegisterScreen({super.key, required this.container});

  Future<void> _openAscForm(BuildContext context) async {
    final opened = await openUrlInSystemBrowser(AppConfig.ascRegistrationFormUrl);
    if (!context.mounted) return;
    if (opened) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Open ASC form'),
        content: SelectableText(
          'Could not open the browser. Paste this URL:\n\n'
          '${AppConfig.ascRegistrationFormUrl}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ASC academy registration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'NetAcad Academy Registration (ASC)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Register the same way as on villagenetacad.co.za: complete the '
              'official ASC Registration Form (Microsoft Forms). That form '
              'captures academy type, contacts, lab/virtual-academy details, '
              'and more — do not use a shortened in-app form.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Digititan ASC supports schools, youth programmes, and community '
              'hubs with onboarding, facilitator enablement, and pathways to '
              'certification and employability.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openAscForm(context),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open ASC Registration Form'),
            ),
            const SizedBox(height: 12),
            Text(
              'Same form as Home → ASC Registration on the website.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

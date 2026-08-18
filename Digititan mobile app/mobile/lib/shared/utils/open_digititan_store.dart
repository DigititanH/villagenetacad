import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';

/// Opens the Digititan Store without a native plugin.
///
/// Why: `url_launcher` compiles Kotlin from Pub Cache on `C:` while this
/// project lives on `S:`. Kotlin incremental caches cannot relativize paths
/// across different drive roots, which breaks `assembleDebug`.
///
/// Prototype approach: copy the URL and show it so the user can open a browser.
Future<void> openDigititanStore(BuildContext context) async {
  final url = AppConfig.digititanStoreUrl;
  await Clipboard.setData(ClipboardData(text: url));
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Store link copied'),
      content: Text(
        'Full shopping is on the Digititan Store website.\n\n'
        'Link copied:\n$url\n\n'
        'Paste into Chrome (or any browser) on this device.\n'
        '(Auto-open browser comes later when the project is not on S:.)',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

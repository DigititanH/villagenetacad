import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';

/// Opens Digititan Store in the system browser.
///
/// Uses a MethodChannel into our own MainActivity (Kotlin on the same drive
/// as the project). Avoids pub.dev url_launcher, which breaks builds when
/// the app is on S: and Pub Cache is on C:.
const _browserChannel = MethodChannel('za.co.digititan.digititan_mobile/browser');

Future<bool> openDigititanStoreUrl() async {
  final url = AppConfig.digititanStoreUrl;
  try {
    final ok = await _browserChannel.invokeMethod<bool>('openUrl', {'url': url});
    return ok == true;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}

/// Tap Store CTA: open browser; if that fails, show dialog with clickable link.
Future<void> openDigititanStore(BuildContext context) async {
  final url = AppConfig.digititanStoreUrl;
  final opened = await openDigititanStoreUrl();
  if (!context.mounted) return;

  if (opened) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Digititan Store website...')),
    );
    return;
  }

  await Clipboard.setData(ClipboardData(text: url));
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Digititan Store website'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tap the link to open the store:'),
          SizedBox(height: 12),
          DigititanStoreLink(),
          SizedBox(height: 12),
          Text(
            'Link also copied to clipboard if the browser does not open.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Blue underlined store URL - tap opens the browser.
class DigititanStoreLink extends StatelessWidget {
  const DigititanStoreLink({super.key});

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.digititanStoreUrl;
    return InkWell(
      onTap: () async {
        final ok = await openDigititanStoreUrl();
        if (!ok) {
          await Clipboard.setData(ClipboardData(text: url));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied: $url')),
            );
          }
        }
      },
      child: Text(
        url,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF13418A),
              decoration: TextDecoration.underline,
              decorationColor: const Color(0xFF13418A),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

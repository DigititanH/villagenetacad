import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';

/// Opens the Village NetAcad shop in the system browser.
///
/// Uses a MethodChannel into our own MainActivity (Kotlin on the same drive
/// as the project). Avoids pub.dev url_launcher, which breaks builds when
/// the app is on S: and Pub Cache is on C:.
const _browserChannel = MethodChannel('za.co.digititan.digititan_mobile/browser');

Future<bool> openVillageNetAcadShopUrl() async {
  return openUrlInSystemBrowser(AppConfig.villageNetAcadShopUrl);
}

Future<bool> openUrlInSystemBrowser(String url) async {
  try {
    final ok = await _browserChannel.invokeMethod<bool>('openUrl', {'url': url});
    return ok == true;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}

/// Opens the shared website cart. User continues to checkout on the site.
Future<bool> openVillageNetAcadCartUrl() async {
  return openUrlInSystemBrowser(AppConfig.villageNetAcadCartUrl);
}

/// Backward-compatible alias.
Future<bool> openDigititanStoreUrl() => openVillageNetAcadShopUrl();

/// Tap Store CTA: open browser; if that fails, show dialog with clickable link.
Future<void> openVillageNetAcadShop(BuildContext context) async {
  final url = AppConfig.villageNetAcadShopUrl;
  final opened = await openVillageNetAcadShopUrl();
  if (!context.mounted) return;

  if (opened) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Village NetAcad shop...')),
    );
    return;
  }

  await Clipboard.setData(ClipboardData(text: url));
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Village NetAcad shop'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tap the link to open the shop:'),
          SizedBox(height: 12),
          VillageNetAcadShopLink(),
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

/// Opens website cart; returns whether the browser launch succeeded.
Future<bool> openVillageNetAcadCart(BuildContext context) async {
  final url = AppConfig.villageNetAcadCartUrl;
  final opened = await openVillageNetAcadCartUrl();
  if (!context.mounted) return opened;

  if (opened) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening website cart for PayFast...')),
    );
    return true;
  }

  await Clipboard.setData(ClipboardData(text: url));
  if (!context.mounted) return false;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Website cart'),
      content: Text(
        'Open this URL to finish checkout:\n\n$url\n\n'
        '(Copied to clipboard.)\n'
        'Sign in on the website with the same account as the app.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  return false;
}

/// Opens an enrol URL (Cisco NetAcad or website `/courses/enrol`).
Future<void> openExternalEnrol(
  BuildContext context, {
  required String url,
  required String successMessage,
}) async {
  final opened = await openUrlInSystemBrowser(url);
  if (!context.mounted) return;

  if (opened) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage)),
    );
    return;
  }

  await Clipboard.setData(ClipboardData(text: url));
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Open in browser'),
      content: Text(
        'Could not open the browser automatically.\n\n$url\n\n'
        '(Copied to clipboard.)',
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

/// Backward-compatible alias.
Future<void> openDigititanStore(BuildContext context) =>
    openVillageNetAcadShop(context);

/// Underlined shop URL — tap opens the browser.
class VillageNetAcadShopLink extends StatelessWidget {
  const VillageNetAcadShopLink({super.key});

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.villageNetAcadShopUrl;
    return InkWell(
      onTap: () async {
        final ok = await openVillageNetAcadShopUrl();
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

/// Backward-compatible alias widget.
class DigititanStoreLink extends StatelessWidget {
  const DigititanStoreLink({super.key});

  @override
  Widget build(BuildContext context) => const VillageNetAcadShopLink();
}

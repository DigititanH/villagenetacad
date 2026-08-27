import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/reseller.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';

class ResellerQrCard extends StatelessWidget {
  final String code;
  final String resellerName;
  final ResellerCodeType codeType;
  final String status;
  final String? academyName;

  const ResellerQrCard({
    super.key,
    required this.code,
    required this.resellerName,
    required this.codeType,
    required this.status,
    this.academyName,
  });

  String get _verifyLink => AppConfig.resellerVerifyPayload(code);

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _verifyLink));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verify link copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final approved = status == 'approved';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              resellerName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('${codeType.label} · $code'),
            if (academyName != null) Text(academyName!),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DigititanColors.muted),
                ),
                child: CustomPaint(
                  painter: _FakeQrPainter(seed: code),
                  size: const Size(160, 160),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _verifyLink,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(status),
                  backgroundColor: approved
                      ? DigititanColors.teal.withOpacity(0.15)
                      : DigititanColors.danger.withOpacity(0.12),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _copyLink(context),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy link'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FakeQrPainter extends CustomPainter {
  final String seed;

  _FakeQrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final hash = seed.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff);
    final cell = size.width / 21;
    final dark = Paint()..color = DigititanColors.primaryDark;
    final light = Paint()..color = Colors.white;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), light);

    for (var row = 0; row < 21; row++) {
      for (var col = 0; col < 21; col++) {
        final inFinder = (row < 7 && col < 7) ||
            (row < 7 && col > 13) ||
            (row > 13 && col < 7);
        final bit = inFinder
            ? _finderBit(row % 7, col % 7)
            : ((hash + row * 17 + col * 13) % 5) < 2;
        if (bit) {
          canvas.drawRect(
            Rect.fromLTWH(col * cell, row * cell, cell, cell),
            dark,
          );
        }
      }
    }
  }

  bool _finderBit(int row, int col) {
    if (row == 0 || row == 6 || col == 0 || col == 6) return true;
    if (row >= 2 && row <= 4 && col >= 2 && col <= 4) return true;
    return false;
  }

  @override
  bool shouldRepaint(covariant _FakeQrPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

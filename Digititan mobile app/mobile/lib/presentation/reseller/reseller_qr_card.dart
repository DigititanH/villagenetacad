import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/reseller.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';

/// Prototype QR mark for reseller legitimacy (no external package).
/// Payload: vna://verify/{CODE} — same as PHP GET /api/resellers/verify/{code}
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

  @override
  Widget build(BuildContext context) {
    final payload = AppConfig.resellerVerifyPayload(code);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DigititanColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DigititanColors.muted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Buyer trust QR',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Customers scan this to confirm you are an approved Digititan reseller.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Center(
            child: _QrMatrix(seed: code, size: 168),
          ),
          const SizedBox(height: 12),
          SelectableText(
            payload,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$resellerName · ${codeType.label} · $status'
            '${academyName == null ? '' : ' · $academyName'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: payload));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verify link copied')),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy verify link'),
          ),
        ],
      ),
    );
  }
}

class _QrMatrix extends StatelessWidget {
  final String seed;
  final double size;

  const _QrMatrix({required this.seed, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _QrPainter(seed: seed),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String seed;

  _QrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white;
    final fg = Paint()..color = DigititanColors.primaryDark;
    canvas.drawRect(Offset.zero & size, bg);

    const cells = 21;
    final cell = size.width / cells;
    final rnd = math.Random(seed.hashCode);

    bool bit(int x, int y) {
      if ((x < 7 && y < 7) ||
          (x >= cells - 7 && y < 7) ||
          (x < 7 && y >= cells - 7)) {
        final inOuter = x == 0 ||
            y == 0 ||
            x == 6 ||
            y == 6 ||
            (x >= cells - 7 && (x == cells - 1 || x == cells - 7)) ||
            (y >= cells - 7 && (y == cells - 1 || y == cells - 7));
        final inInner = (x >= 2 && x <= 4 && y >= 2 && y <= 4) ||
            (x >= cells - 5 && x <= cells - 3 && y >= 2 && y <= 4) ||
            (x >= 2 && x <= 4 && y >= cells - 5 && y <= cells - 3);
        return inOuter || inInner;
      }
      return rnd.nextBool();
    }

    for (var y = 0; y < cells; y++) {
      for (var x = 0; x < cells; x++) {
        if (bit(x, y)) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell, cell),
            fg,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

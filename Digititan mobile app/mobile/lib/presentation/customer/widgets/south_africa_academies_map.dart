import 'package:flutter/material.dart';

import '../../../domain/entities/academy.dart';

/// Prototype South Africa map (no Google Maps plugin — S-drive safe).
///
/// Flow:
/// 1. Tap a province region -> filter academies
/// 2. Pins show academy locations
/// 3. Tap a pin -> open that academy
class SouthAfricaAcademiesMap extends StatelessWidget {
  final String? selectedProvince;
  final List<Academy> academies;
  final ValueChanged<String> onProvinceSelected;
  final ValueChanged<Academy> onAcademySelected;

  const SouthAfricaAcademiesMap({
    super.key,
    required this.selectedProvince,
    required this.academies,
    required this.onProvinceSelected,
    required this.onAcademySelected,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.85,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onTapUp: (details) {
              final province = SaMapGeometry.hitTestProvince(
                details.localPosition,
                size,
              );
              if (province != null) {
                onProvinceSelected(province);
                return;
              }
              final academy = SaMapGeometry.hitTestAcademy(
                details.localPosition,
                size,
                academies,
                selectedProvince,
              );
              if (academy != null) {
                onAcademySelected(academy);
              }
            },
            child: CustomPaint(
              size: size,
              painter: _SaMapPainter(
                selectedProvince: selectedProvince,
                academies: academies,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Normalized SA layout helpers (lng 16..33, lat -22..-35).
class SaMapGeometry {
  static const minLng = 16.0;
  static const maxLng = 33.0;
  static const maxLat = -22.0;
  static const minLat = -35.0;

  static Offset latLngToOffset(double lat, double lng, Size size) {
    final x = ((lng - minLng) / (maxLng - minLng)).clamp(0.0, 1.0);
    final y = ((maxLat - lat) / (maxLat - minLat)).clamp(0.0, 1.0);
    return Offset(x * size.width, y * size.height);
  }

  /// Approximate tappable rectangles for each province (normalized 0..1).
  static const Map<String, Rect> provinceNormRects = {
    'Limpopo': Rect.fromLTWH(0.48, 0.02, 0.30, 0.16),
    'Mpumalanga': Rect.fromLTWH(0.62, 0.16, 0.22, 0.14),
    'Gauteng': Rect.fromLTWH(0.52, 0.20, 0.12, 0.08),
    'North West': Rect.fromLTWH(0.38, 0.18, 0.16, 0.14),
    'Free State': Rect.fromLTWH(0.42, 0.30, 0.20, 0.14),
    'KwaZulu-Natal': Rect.fromLTWH(0.62, 0.30, 0.22, 0.22),
    'Northern Cape': Rect.fromLTWH(0.12, 0.22, 0.30, 0.32),
    'Eastern Cape': Rect.fromLTWH(0.42, 0.44, 0.28, 0.22),
    'Western Cape': Rect.fromLTWH(0.10, 0.52, 0.30, 0.30),
  };

  static String? hitTestProvince(Offset local, Size size) {
    final nx = local.dx / size.width;
    final ny = local.dy / size.height;
    // Prefer smaller provinces first (Gauteng over neighbours).
    const order = [
      'Gauteng',
      'Mpumalanga',
      'North West',
      'Free State',
      'Limpopo',
      'KwaZulu-Natal',
      'Eastern Cape',
      'Western Cape',
      'Northern Cape',
    ];
    for (final name in order) {
      final r = provinceNormRects[name]!;
      if (r.contains(Offset(nx, ny))) return name;
    }
    return null;
  }

  static Academy? hitTestAcademy(
    Offset local,
    Size size,
    List<Academy> academies,
    String? selectedProvince,
  ) {
    final visible = selectedProvince == null || selectedProvince == 'All'
        ? academies
        : academies.where((a) => a.province == selectedProvince);
    Academy? best;
    var bestDist = 28.0;
    for (final a in visible) {
      final p = latLngToOffset(a.latitude, a.longitude, size);
      final d = (p - local).distance;
      if (d < bestDist) {
        bestDist = d;
        best = a;
      }
    }
    return best;
  }
}

class _SaMapPainter extends CustomPainter {
  final String? selectedProvince;
  final List<Academy> academies;

  _SaMapPainter({
    required this.selectedProvince,
    required this.academies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ocean = Paint()..color = const Color(0xFFE8F4FC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      ocean,
    );

    // Soft SA land silhouette (approximate).
    final landPath = Path()
      ..moveTo(size.width * 0.18, size.height * 0.18)
      ..lineTo(size.width * 0.55, size.height * 0.05)
      ..lineTo(size.width * 0.82, size.height * 0.18)
      ..lineTo(size.width * 0.88, size.height * 0.42)
      ..lineTo(size.width * 0.72, size.height * 0.72)
      ..lineTo(size.width * 0.42, size.height * 0.88)
      ..lineTo(size.width * 0.18, size.height * 0.78)
      ..lineTo(size.width * 0.10, size.height * 0.48)
      ..close();

    canvas.drawPath(
      landPath,
      Paint()..color = const Color(0xFFD8E8D0),
    );
    canvas.drawPath(
      landPath,
      Paint()
        ..color = const Color(0xFF6B8F71)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    for (final entry in SaMapGeometry.provinceNormRects.entries) {
      final name = entry.key;
      final nr = entry.value;
      final rect = Rect.fromLTWH(
        nr.left * size.width,
        nr.top * size.height,
        nr.width * size.width,
        nr.height * size.height,
      );
      final selected = selectedProvince == name;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = selected
              ? const Color(0xFF2F6FED).withOpacity(0.35)
              : const Color(0xFF2A5D3A).withOpacity(0.12),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = selected ? const Color(0xFF2F6FED) : const Color(0xFF4A6B52)
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2.2 : 1,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: _shortName(name),
          style: TextStyle(
            color: selected ? const Color(0xFF1A3A8A) : const Color(0xFF2A4030),
            fontSize: 9,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width - 4);
      tp.paint(
        canvas,
        Offset(
          rect.left + (rect.width - tp.width) / 2,
          rect.top + (rect.height - tp.height) / 2,
        ),
      );
    }

    final visible = selectedProvince == null || selectedProvince == 'All'
        ? academies
        : academies.where((a) => a.province == selectedProvince).toList();

    for (final a in visible) {
      final p = SaMapGeometry.latLngToOffset(a.latitude, a.longitude, size);
      canvas.drawCircle(p, 7, Paint()..color = Colors.white);
      canvas.drawCircle(p, 5.5, Paint()..color = const Color(0xFFC62828));
      canvas.drawCircle(
        p.translate(0, -0.5),
        1.8,
        Paint()..color = Colors.white,
      );
    }
  }

  String _shortName(String name) {
    switch (name) {
      case 'KwaZulu-Natal':
        return 'KZN';
      case 'Eastern Cape':
        return 'EC';
      case 'Western Cape':
        return 'WC';
      case 'Northern Cape':
        return 'NC';
      case 'North West':
        return 'NW';
      case 'Free State':
        return 'FS';
      case 'Mpumalanga':
        return 'MP';
      default:
        return name;
    }
  }

  @override
  bool shouldRepaint(covariant _SaMapPainter oldDelegate) {
    return oldDelegate.selectedProvince != selectedProvince ||
        oldDelegate.academies != academies;
  }
}

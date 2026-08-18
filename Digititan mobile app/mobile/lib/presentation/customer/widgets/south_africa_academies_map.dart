import 'package:flutter/material.dart';

import '../../../domain/entities/academy.dart';
import 'sa_province_paths.dart';

/// Real South Africa provinces map (geographic outlines).
/// Tap a province -> filter academies. Red pins = academy locations.
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
      aspectRatio: 1.15,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F4FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB0C4DE)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
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
        ),
      ),
    );
  }
}

class SaMapGeometry {
  static final Map<String, Path> _provincePaths = {
    for (final e in SaProvincePaths.pathData.entries)
      e.key: parseSvgPath(e.value),
  };

  static Path pathFor(String province) => _provincePaths[province]!;

  static Matrix4 svgToWidget(Size size) {
    const vb = SaProvincePaths.viewBox;
    final sx = size.width / (vb.maxX - vb.minX);
    final sy = size.height / (vb.maxY - vb.minY);
    final s = sx < sy ? sx : sy;
    final dx = (size.width - (vb.maxX - vb.minX) * s) / 2;
    final dy = (size.height - (vb.maxY - vb.minY) * s) / 2;
    // Build transform: translate -> scale -> translate (SVG space to widget).
    return Matrix4.translationValues(dx, dy, 0) *
        Matrix4.diagonal3Values(s, s, 1) *
        Matrix4.translationValues(-vb.minX, -vb.minY, 0);
  }

  static Offset widgetToSvg(Offset local, Size size) {
    final m = svgToWidget(size);
    final inv = Matrix4.tryInvert(m);
    if (inv == null) return local;
    return MatrixUtils.transformPoint(inv, local);
  }

  /// Calibrated approx. projection: WGS84 -> SVG coords used by the province paths.
  static Offset latLngToSvg(double lat, double lng) {
    const a = 25.67;
    const b = -195.0;
    const c = -32.64;
    const d = -676.4;
    return Offset(a * lng + b, c * lat + d);
  }

  static Offset latLngToWidget(double lat, double lng, Size size) {
    return MatrixUtils.transformPoint(
      svgToWidget(size),
      latLngToSvg(lat, lng),
    );
  }

  static String? hitTestProvince(Offset local, Size size) {
    final svgPt = widgetToSvg(local, size);
    // Prefer smaller provinces first.
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
      if (pathFor(name).contains(svgPt)) return name;
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
      final p = latLngToWidget(a.latitude, a.longitude, size);
      final d = (p - local).distance;
      if (d < bestDist) {
        bestDist = d;
        best = a;
      }
    }
    return best;
  }
}

/// Minimal SVG path parser for M / m / L / l / Z / z (enough for ZA province paths).
Path parseSvgPath(String d) {
  final path = Path();
  final tokens = <Object>[];
  final re = RegExp(r'([MmZzLl])|(-?\d*\.?\d+(?:e[-+]?\d+)?)');
  for (final m in re.allMatches(d.replaceAll(',', ' '))) {
    if (m.group(1) != null) {
      tokens.add(m.group(1)!);
    } else {
      tokens.add(double.parse(m.group(2)!));
    }
  }

  var i = 0;
  String? cmd;
  var cx = 0.0;
  var cy = 0.0;
  var sx = 0.0;
  var sy = 0.0;

  double next() => tokens[i++] as double;

  while (i < tokens.length) {
    final t = tokens[i];
    if (t is String) {
      cmd = t;
      i++;
      continue;
    }
    switch (cmd) {
      case 'M':
        cx = next();
        cy = next();
        sx = cx;
        sy = cy;
        path.moveTo(cx, cy);
        cmd = 'L';
        break;
      case 'm':
        cx += next();
        cy += next();
        sx = cx;
        sy = cy;
        path.moveTo(cx, cy);
        cmd = 'l';
        break;
      case 'L':
        cx = next();
        cy = next();
        path.lineTo(cx, cy);
        break;
      case 'l':
        cx += next();
        cy += next();
        path.lineTo(cx, cy);
        break;
      case 'Z':
      case 'z':
        path.close();
        cx = sx;
        cy = sy;
        break;
      default:
        throw StateError('Unsupported SVG command: $cmd');
    }
  }
  return path;
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
    final matrix = SaMapGeometry.svgToWidget(size);
    canvas.save();
    canvas.transform(matrix.storage);

    // Ocean already from parent; draw provinces.
    for (final name in SaProvincePaths.pathData.keys) {
      final path = SaMapGeometry.pathFor(name);
      final selected = selectedProvince == name;
      canvas.drawPath(
        path,
        Paint()
          ..color = selected
              ? const Color(0xFF2F6FED)
              : const Color(0xFF6B9B6E),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2.4 : 1.2,
      );
    }

    // Province labels
    for (final e in SaProvincePaths.labels.entries) {
      final selected = selectedProvince == e.key;
      final tp = TextPainter(
        text: TextSpan(
          text: _short(e.key),
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF1B3A1F),
            fontSize: e.key == 'Gauteng' ? 9 : 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(e.value.$1 - tp.width / 2, e.value.$2 - tp.height / 2),
      );
    }

    canvas.restore();

    // Pins in widget space
    final visible = selectedProvince == null || selectedProvince == 'All'
        ? academies
        : academies.where((a) => a.province == selectedProvince).toList();

    for (final a in visible) {
      final p = SaMapGeometry.latLngToWidget(a.latitude, a.longitude, size);
      // Skip pins that fall far outside the cropped mainland view.
      if (p.dx < -20 || p.dy < -20 || p.dx > size.width + 20 || p.dy > size.height + 20) {
        continue;
      }
      canvas.drawCircle(p, 8, Paint()..color = Colors.white);
      canvas.drawCircle(p, 6, Paint()..color = const Color(0xFFC62828));
      canvas.drawCircle(p.translate(0, -1), 2, Paint()..color = Colors.white);
    }
  }

  String _short(String name) {
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

import 'package:flutter/material.dart';

import '../../../shared/theme/digititan_theme.dart';

/// Network course photo — fills parent (use inside AspectRatio / SizedBox).
class CourseImage extends StatelessWidget {
  final String? imageUrl;
  final BorderRadius? borderRadius;

  const CourseImage({
    super.key,
    required this.imageUrl,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final url = imageUrl?.trim();
    return ClipRRect(
      borderRadius: radius,
      child: url == null || url.isEmpty
          ? _placeholder()
          : Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _placeholder(loading: true);
              },
              errorBuilder: (_, _, _) => _placeholder(broken: true),
            ),
    );
  }

  Widget _placeholder({bool loading = false, bool broken = false}) {
    return ColoredBox(
      color: DigititanColors.muted,
      child: Center(
        child: loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                broken ? Icons.broken_image_outlined : Icons.school_outlined,
                size: 40,
                color: DigititanColors.primary,
              ),
      ),
    );
  }
}

/// Website-style digital course tile: photo + gradient + hours/price/level.
class CourseDigitalTile extends StatelessWidget {
  final String? imageUrl;
  final int hours;
  final String priceLabel;
  final String level;

  const CourseDigitalTile({
    super.key,
    required this.imageUrl,
    required this.hours,
    required this.priceLabel,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CourseImage(imageUrl: imageUrl),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0x26000000),
                  Color(0xB3000000),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('${hours}H'),
                  const Spacer(),
                  Text(priceLabel.toUpperCase()),
                  const Spacer(),
                  Text(level.toUpperCase()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small square thumb for Home / compact rows.
class CourseImageThumb extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const CourseImageThumb({
    super.key,
    required this.imageUrl,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url.isEmpty
            ? const ColoredBox(
                color: DigititanColors.muted,
                child: Icon(Icons.school_outlined, color: DigititanColors.primary),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: DigititanColors.muted,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: DigititanColors.primary,
                  ),
                ),
              ),
      ),
    );
  }
}

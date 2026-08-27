import 'package:flutter/material.dart';

import '../../../shared/theme/digititan_theme.dart';

/// Course hero / card image (website Unsplash URLs).
class CourseImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final BorderRadius? borderRadius;

  const CourseImage({
    super.key,
    required this.imageUrl,
    this.height = 180,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    final url = imageUrl?.trim();
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: url == null || url.isEmpty
            ? _placeholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: height,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: DigititanColors.muted.withValues(alpha: 0.25),
                    child: const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, _, _) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder({double iconSize = 40}) {
    return ColoredBox(
      color: DigititanColors.muted.withValues(alpha: 0.35),
      child: Center(
        child: Icon(
          Icons.school_outlined,
          size: iconSize,
          color: DigititanColors.primary,
        ),
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
            ? ColoredBox(
                color: DigititanColors.muted.withValues(alpha: 0.35),
                child: const Icon(
                  Icons.school_outlined,
                  color: DigititanColors.primary,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: DigititanColors.muted.withValues(alpha: 0.35),
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: DigititanColors.primary,
                  ),
                ),
              ),
      ),
    );
  }
}

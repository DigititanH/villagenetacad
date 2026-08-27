import 'package:flutter/material.dart';

import '../theme/digititan_theme.dart';
import '../utils/media_url.dart';

/// Product thumb / hero image with a soft placeholder when missing.
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.size = 56,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final url = resolveMediaUrl(imageUrl);
    final radius = borderRadius ?? BorderRadius.circular(12);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? ColoredBox(
                color: DigititanColors.muted.withValues(alpha: 0.35),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: DigititanColors.primary,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
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

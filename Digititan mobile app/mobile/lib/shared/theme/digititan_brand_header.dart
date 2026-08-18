import 'package:flutter/material.dart';

import 'digititan_theme.dart';

/// Digititan wordmark + logo mark for branded screens.
class DigititanBrandHeader extends StatelessWidget {
  final bool compact;
  final String? tagline;

  const DigititanBrandHeader({
    super.key,
    this.compact = false,
    this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 40.0 : 88.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(compact ? 8 : 16),
          child: Image.asset(
            'assets/branding/logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: logoSize,
              height: logoSize,
              alignment: Alignment.center,
              color: DigititanColors.primaryDark,
              child: Text(
                'D',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: logoSize * 0.45,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 14),
        Text(
          'DIGITITAN',
          style: TextStyle(
            fontSize: compact ? 20 : 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
            color: DigititanColors.primaryDark,
          ),
        ),
        if (tagline != null) ...[
          const SizedBox(height: 6),
          Text(
            tagline!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              color: DigititanColors.foreground,
            ),
          ),
        ],
      ],
    );
  }
}

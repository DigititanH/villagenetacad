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

  static const logoAsset = 'assets/branding/logo.png';

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 56.0 : 120.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          logoAsset,
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: logoSize,
            height: logoSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DigititanColors.primaryDark,
              borderRadius: BorderRadius.circular(16),
            ),
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
        SizedBox(height: compact ? 8 : 12),
        Text(
          'DIGITITAN',
          style: TextStyle(
            fontSize: compact ? 22 : 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.0,
            color: DigititanColors.primaryDark,
          ),
        ),
        SizedBox(height: compact ? 2 : 4),
        Text(
          'Village NetAcad',
          style: TextStyle(
            fontSize: compact ? 13 : 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: DigititanColors.foreground.withOpacity(0.75),
          ),
        ),
        if (tagline != null) ...[
          const SizedBox(height: 8),
          Text(
            tagline!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              height: 1.4,
              color: DigititanColors.foreground.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }
}

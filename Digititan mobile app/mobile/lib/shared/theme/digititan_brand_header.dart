import 'package:flutter/material.dart';

import 'digititan_theme.dart';

/// Digititan wordmark + logo mark for branded screens.
class DigititanBrandHeader extends StatelessWidget {
  final bool compact;

  const DigititanBrandHeader({
    super.key,
    this.compact = false,
  });

  static const logoAsset =
      'assets/branding/VillageNetAcadTransparentBackground.png';

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 72.0 : 176.0;
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
          'Powered by',
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: DigititanColors.foreground.withOpacity(0.7),
          ),
        ),
        SizedBox(height: compact ? 2 : 4),
        Text(
          'DIGITITAN',
          style: TextStyle(
            fontSize: compact ? 22 : 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.0,
            color: DigititanColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/digititan_theme.dart';

/// Small strip for stakeholder demos (branded, not amber generic).
class DemoBanner extends StatelessWidget {
  final String message;

  const DemoBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DigititanColors.primaryDark.withOpacity(0.92),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 18, color: DigititanColors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

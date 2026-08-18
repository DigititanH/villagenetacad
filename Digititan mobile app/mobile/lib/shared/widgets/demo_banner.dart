import 'package:flutter/material.dart';

/// Small non-branded strip for stakeholder demos.
class DemoBanner extends StatelessWidget {
  final String message;

  const DemoBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.amber.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: Colors.brown.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 12, color: Colors.brown.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

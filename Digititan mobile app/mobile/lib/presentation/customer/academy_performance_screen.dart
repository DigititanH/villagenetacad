import 'package:flutter/material.dart';

import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';

class AcademyPerformanceScreen extends StatelessWidget {
  const AcademyPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = List<AcademyPerformanceStat>.from(DemoHub.instance.academyStats)
      ..sort((a, b) {
        final byCompletions = b.completions.compareTo(a.completions);
        if (byCompletions != 0) return byCompletions;
        return b.sales.compareTo(a.sales);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Academy performance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Rankings (registrations / sales / completions)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Prototype league table — live data arrives in Phase 9.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ...List.generate(stats.length, (i) {
            final s = stats[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: DigititanColors.primaryDark,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(s.academyName),
                subtitle: Text(
                  'Registrations ${s.registrations} · Sales ${s.sales} · '
                  'Completions ${s.completions}',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';

class _AcademyStatRow {
  final String academyId;
  final String academyName;
  final int registrations;
  final int sales;
  final int completions;

  const _AcademyStatRow({
    required this.academyId,
    required this.academyName,
    required this.registrations,
    required this.sales,
    required this.completions,
  });
}

const _fallbackStats = [
  _AcademyStatRow(
    academyId: 'ac-lesedi',
    academyName: 'Lesedi Labatu Academy',
    registrations: 142,
    sales: 38,
    completions: 67,
  ),
  _AcademyStatRow(
    academyId: 'ac-soweto',
    academyName: 'Soweto Digital Hub',
    registrations: 98,
    sales: 22,
    completions: 54,
  ),
  _AcademyStatRow(
    academyId: 'ac-cpt',
    academyName: 'Cape Flats NetAcad Centre',
    registrations: 76,
    sales: 31,
    completions: 48,
  ),
  _AcademyStatRow(
    academyId: 'ac-dbn',
    academyName: 'eThekwini Skills Academy',
    registrations: 64,
    sales: 19,
    completions: 41,
  ),
  _AcademyStatRow(
    academyId: 'ac-polokwane',
    academyName: 'Limpopo Future Coders',
    registrations: 55,
    sales: 12,
    completions: 29,
  ),
];

List<_AcademyStatRow> _loadStats() {
  try {
    final raw = (DemoHub.instance as dynamic).academyStats as Map<String, dynamic>?;
    if (raw == null || raw.isEmpty) return _sorted(_fallbackStats);

    final rows = raw.entries.map((e) {
      final v = e.value as Map<String, dynamic>;
      return _AcademyStatRow(
        academyId: e.key,
        academyName: '${v['name'] ?? e.key}',
        registrations: (v['registrations'] as num?)?.toInt() ?? 0,
        sales: (v['sales'] as num?)?.toInt() ?? 0,
        completions: (v['completions'] as num?)?.toInt() ?? 0,
      );
    }).toList();
    return _sorted(rows);
  } catch (_) {
    return _sorted(_fallbackStats);
  }
}

List<_AcademyStatRow> _sorted(List<_AcademyStatRow> rows) {
  final copy = List<_AcademyStatRow>.from(rows);
  copy.sort((a, b) {
    final byCompletions = b.completions.compareTo(a.completions);
    if (byCompletions != 0) return byCompletions;
    return b.sales.compareTo(a.sales);
  });
  return copy;
}

class AcademyPerformanceScreen extends StatelessWidget {
  const AcademyPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = _loadStats();

    return Scaffold(
      appBar: AppBar(title: const Text('Academy performance')),
      body: Column(
        children: [
          const DemoBanner(message: 'Demo rankings — sample academy stats'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final row = stats[index];
                final rank = index + 1;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: DigititanColors.primary,
                              child: Text(
                                '$rank',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                row.academyName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: MetricTile(
                                label: 'Registrations',
                                value: '${row.registrations}',
                                icon: Icons.person_add_alt_1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricTile(
                                label: 'Sales',
                                value: '${row.sales}',
                                icon: Icons.shopping_bag_outlined,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MetricTile(
                                label: 'Completions',
                                value: '${row.completions}',
                                icon: Icons.school_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

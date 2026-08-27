import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/training_offer.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/result/result.dart';
import '../../../shared/theme/digititan_theme.dart';
import '../training_detail_screen.dart';
import '../widgets/course_image.dart';

/// Website category order (same chips as /courses).
const _kCategories = <String>[
  'All Courses',
  'Digital Literacy',
  'IT Essentials',
  'Networking',
  'Cybersecurity',
  'AI',
];

class TrainingTab extends StatefulWidget {
  final AppContainer container;
  final User user;

  const TrainingTab({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  State<TrainingTab> createState() => _TrainingTabState();
}

class _TrainingTabState extends State<TrainingTab> {
  List<TrainingOffer> _offers = [];
  bool _loading = true;
  String? _error;
  String _category = 'All Courses';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.container.getTrainingOffers();
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _offers = data;
        case Failure(:final message):
          _error = message;
      }
    });
  }

  List<TrainingOffer> get _filtered {
    if (_category == 'All Courses') return _offers;
    return _offers.where((o) => o.category == _category).toList();
  }

  void _open(TrainingOffer o) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainingDetailScreen(
          container: widget.container,
          user: widget.user,
          trainingId: o.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text('Courses'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: DigititanColors.teal))
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _HeroHeader()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          'Cisco NetAcad Course Catalog',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 44,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          scrollDirection: Axis.horizontal,
                          itemCount: _kCategories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final label = _kCategories[i];
                            final selected = label == _category;
                            return ChoiceChip(
                              label: Text(label),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _category = label),
                              selectedColor: DigititanColors.teal,
                              backgroundColor: const Color(0xFF1A2438),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? const Color(0xFF0B1220)
                                    : Colors.white70,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? DigititanColors.teal
                                    : const Color(0xFF2A3A55),
                              ),
                              visualDensity: VisualDensity.compact,
                            );
                          },
                        ),
                      ),
                    ),
                    if (_filtered.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'No courses in this category',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      )
                    else
                      // Force rebuild marker when category changes — image cards.
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        sliver: SliverList.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 18),
                          itemBuilder: (context, i) {
                            final o = _filtered[i];
                            return _WebsiteStyleCourseCard(
                              offer: o,
                              onTap: () => _open(o),
                            );
                          },
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B1220),
            Color(0xFF12263F),
            Color(0xFF0E3A4F),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VILLAGE NETACAD · CISCO',
            style: TextStyle(
              color: DigititanColors.teal.withValues(alpha: 0.95),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Digital skills courses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Same catalogue & photos as villagenetacad.co.za/courses. '
            'Free → Cisco · Paid CCNA → website PayFast.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.4,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Matches live site course card: 16:10 photo screen + title block below.
class _WebsiteStyleCourseCard extends StatelessWidget {
  final TrainingOffer offer;
  final VoidCallback onTap;

  const _WebsiteStyleCourseCard({
    required this.offer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF142033),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CourseDigitalTile(
              imageUrl: offer.imageUrl,
              hours: offer.hours,
              priceLabel: offer.priceLabel,
              level: offer.level,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.category.toUpperCase(),
                    style: TextStyle(
                      color: DigititanColors.teal.withValues(alpha: 0.95),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    offer.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        offer.isPaidOnWebsite
                            ? Icons.payments_outlined
                            : Icons.open_in_new,
                        size: 16,
                        color: DigititanColors.teal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        offer.isPaidOnWebsite
                            ? 'Pay & enrol on website'
                            : 'Enroll on Cisco',
                        style: const TextStyle(
                          color: DigititanColors.teal,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        color: DigititanColors.teal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

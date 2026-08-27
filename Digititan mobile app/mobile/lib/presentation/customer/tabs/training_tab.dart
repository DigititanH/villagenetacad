import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/training_offer.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/result/result.dart';
import '../../../shared/theme/digititan_theme.dart';
import '../training_detail_screen.dart';
import '../widgets/course_image.dart';

/// Category chips - same labels as website, app light theme.
const _kCategories = <String>[
  'All Courses',
  'Digital Literacy',
  'IT Essentials',
  'Networking',
  'Cybersecurity',
  'AI',
];

const _kPageSizes = <int>[5, 10, 15];
const _kDefaultPageSize = 5;

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
  int _pageSize = _kDefaultPageSize;
  int _page = 1; // 1-based

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
          _page = 1;
        case Failure(:final message):
          _error = message;
      }
    });
  }

  List<TrainingOffer> get _filtered {
    if (_category == 'All Courses') return _offers;
    return _offers.where((o) => o.category == _category).toList();
  }

  int get _totalPages {
    final n = _filtered.length;
    if (n == 0) return 1;
    return ((n + _pageSize - 1) / _pageSize).floor();
  }

  List<TrainingOffer> get _pageItems {
    final all = _filtered;
    if (all.isEmpty) return const [];
    final start = (_page - 1) * _pageSize;
    if (start >= all.length) return const [];
    final end = (start + _pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  void _setCategory(String label) {
    setState(() {
      _category = label;
      _page = 1;
    });
  }

  void _setPageSize(int size) {
    setState(() {
      _pageSize = size;
      _page = 1;
    });
  }

  void _goToPage(int page) {
    final max = _totalPages;
    final next = page.clamp(1, max);
    if (next == _page) return;
    setState(() => _page = next);
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
    final filtered = _filtered;
    final pageItems = _pageItems;
    final total = filtered.length;
    final totalPages = _totalPages;
    final from = total == 0 ? 0 : ((_page - 1) * _pageSize) + 1;
    final to = total == 0 ? 0 : (from + pageItems.length - 1);

    return Scaffold(
      backgroundColor: DigititanColors.background,
      appBar: AppBar(title: const Text('Courses')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cisco NetAcad catalogue',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Same courses & photos as the website. '
                              'Free -> Cisco · Paid CCNA -> website PayFast.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
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
                            return FilterChip(
                              label: Text(label),
                              selected: selected,
                              showCheckmark: false,
                              onSelected: (_) => _setCategory(label),
                              selectedColor: DigititanColors.primary,
                              backgroundColor: DigititanColors.surface,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : DigititanColors.foreground,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? DigititanColors.primary
                                    : DigititanColors.muted,
                              ),
                              visualDensity: VisualDensity.compact,
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: _PageSizeBar(
                          pageSize: _pageSize,
                          onChanged: _setPageSize,
                          from: from,
                          to: to,
                          total: total,
                        ),
                      ),
                    ),
                    if (pageItems.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('No courses in this category')),
                      )
                    else ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        sliver: SliverList.separated(
                          itemCount: pageItems.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, i) {
                            final o = pageItems[i];
                            return _CoursePhotoCard(
                              offer: o,
                              onTap: () => _open(o),
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                          child: _Pager(
                            page: _page,
                            totalPages: totalPages,
                            onPrev: () => _goToPage(_page - 1),
                            onNext: () => _goToPage(_page + 1),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _PageSizeBar extends StatelessWidget {
  final int pageSize;
  final ValueChanged<int> onChanged;
  final int from;
  final int to;
  final int total;

  const _PageSizeBar({
    required this.pageSize,
    required this.onChanged,
    required this.from,
    required this.to,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            total == 0 ? '0 courses' : 'Showing $from-$to of $total',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text(
          'Per page',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: DigititanColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: DigititanColors.muted),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: pageSize,
              isDense: true,
              items: [
                for (final n in _kPageSizes)
                  DropdownMenuItem(value: n, child: Text('$n')),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Pager extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _Pager({
    required this.page,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final canPrev = page > 1;
    final canNext = page < totalPages;
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: canPrev ? onPrev : null,
          icon: const Icon(Icons.chevron_left, size: 18),
          label: const Text('Prev'),
        ),
        Expanded(
          child: Text(
            'Page $page of $totalPages',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: canNext ? onNext : null,
          icon: const Icon(Icons.chevron_right, size: 18),
          label: const Text('Next'),
        ),
      ],
    );
  }
}

/// Light-theme photo card - matches Home/Store surfaces, keeps Unsplash tile.
class _CoursePhotoCard extends StatelessWidget {
  final TrainingOffer offer;
  final VoidCallback onTap;

  const _CoursePhotoCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DigititanColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: DigititanColors.muted),
      ),
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: DigititanColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    offer.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        offer.isPaidOnWebsite
                            ? Icons.payments_outlined
                            : Icons.open_in_new,
                        size: 16,
                        color: DigititanColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        offer.isPaidOnWebsite
                            ? 'Pay & enrol on website'
                            : 'Enroll on Cisco',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: DigititanColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        color: DigititanColors.primary,
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

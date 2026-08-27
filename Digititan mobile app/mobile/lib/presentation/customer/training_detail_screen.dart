import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/training_offer.dart';
import '../../domain/entities/user.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/utils/open_digititan_store.dart';
import 'widgets/course_image.dart';

class TrainingDetailScreen extends StatefulWidget {
  final AppContainer container;
  final User user;
  final String trainingId;

  const TrainingDetailScreen({
    super.key,
    required this.container,
    required this.user,
    required this.trainingId,
  });

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  TrainingOffer? _offer;
  bool _loading = true;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = widget.container.trainingRepository;
    final offer = await repo.getOfferById(widget.trainingId);
    if (!mounted) return;
    setState(() {
      _offer = offer;
      _loading = false;
    });
  }

  Future<void> _enrol() async {
    final offer = _offer;
    if (offer == null || _opening) return;

    setState(() => _opening = true);
    try {
      if (offer.isPaidOnWebsite) {
        final url = AppConfig.villageNetAcadCoursesEnrolUrl(
          courseTitle: offer.title,
        );
        await openExternalEnrol(
          context,
          url: url,
          successMessage: 'Opening website CCNA enrol (PayFast)...',
        );
      } else if (offer.isFreeCisco) {
        await openExternalEnrol(
          context,
          url: offer.ciscoEnrollUrl!,
          successMessage: 'Opening Cisco NetAcad enrol...',
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enrol link is not configured for this course'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = _offer;
    return Scaffold(
      backgroundColor: DigititanColors.background,
      appBar: AppBar(title: const Text('Course detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : offer == null
              ? const Center(child: Text('Course not found'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          CourseImage(
                            imageUrl: offer.imageUrl,
                            height: 240,
                            borderRadius: BorderRadius.zero,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  offer.category.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: DigititanColors.primary,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.7,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  offer.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _MetaChip(
                                      icon: Icons.schedule,
                                      label: '${offer.hours} hours',
                                    ),
                                    _MetaChip(
                                      icon: Icons.stacked_bar_chart,
                                      label: offer.level,
                                    ),
                                    _MetaChip(
                                      icon: offer.isPaidOnWebsite
                                          ? Icons.payments_outlined
                                          : Icons.card_giftcard_outlined,
                                      label: offer.priceLabel,
                                      highlight: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  offer.summary,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(height: 1.45),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: DigititanColors.softBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    offer.isPaidOnWebsite
                                        ? 'Payment is completed on villagenetacad.co.za '
                                            '(PayFast) — same as shop checkout. No in-app card entry.'
                                        : 'You enrol on Cisco NetAcad under Village NetAcad. '
                                            'Learning happens on Cisco (no in-app LMS).',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _opening ? null : _enrol,
                            child: Text(
                              _opening
                                  ? 'Opening...'
                                  : offer.isPaidOnWebsite
                                      ? 'Pay & enrol on website'
                                      : 'Enroll on Cisco',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? DigititanColors.softGreen : DigititanColors.muted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: DigititanColors.primaryDark),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: DigititanColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

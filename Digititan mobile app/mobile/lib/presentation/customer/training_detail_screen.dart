import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/training_offer.dart';
import '../../domain/entities/user.dart';
import '../../shared/config/app_config.dart';
import '../../shared/utils/open_digititan_store.dart';

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
          const SnackBar(content: Text('Enrol link is not configured for this course')),
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
      appBar: AppBar(title: const Text('Course detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : offer == null
              ? const Center(child: Text('Course not found'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Text(
                        offer.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${offer.category} · ${offer.level} · ${offer.hours} hours · ${offer.priceLabel}',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              offer.isPaidOnWebsite
                                  ? 'Paid on website'
                                  : 'Free on Cisco',
                            ),
                          ),
                          if (offer.recruitmentOpen)
                            const Chip(label: Text('Open for enrol')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(offer.summary),
                      const SizedBox(height: 12),
                      Text(
                        offer.isPaidOnWebsite
                            ? 'Payment is completed on villagenetacad.co.za '
                                '(PayFast) — same as shop checkout. No in-app card entry.'
                            : 'You will enrol on Cisco NetAcad under Village NetAcad. '
                                'Learning happens on Cisco (no in-app LMS).',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _opening ? null : _enrol,
                        child: Text(
                          _opening
                              ? 'Opening...'
                              : offer.isPaidOnWebsite
                                  ? 'Pay & enrol on website'
                                  : 'Enroll on Cisco',
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

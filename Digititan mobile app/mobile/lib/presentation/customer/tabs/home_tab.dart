import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/programme_highlight.dart';
import '../../../domain/entities/training_offer.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/result/result.dart';
import '../../../shared/theme/digititan_theme.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../../shared/widgets/product_price_text.dart';
import '../product_detail_screen.dart';
import '../training_detail_screen.dart';

class HomeTab extends StatefulWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onOpenTraining;
  final VoidCallback? onOpenStore;

  const HomeTab({
    super.key,
    required this.container,
    required this.user,
    required this.onOpenTraining,
    this.onOpenStore,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<ProgrammeHighlight> _programmes = [];
  List<TrainingOffer> _offers = [];
  List<Product> _bestSellers = [];
  List<Product> _promos = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final programmesResult = await widget.container.getProgrammes();
    final offersResult = await widget.container.getTrainingOffers();
    final products = await widget.container.storeRepository.getProducts();
    if (!mounted) return;

    setState(() {
      _loading = false;
      _bestSellers = products.where((p) => p.isBestSeller).take(4).toList();
      _promos = products.where((p) => p.onPromotion).take(4).toList();
      switch (programmesResult) {
        case Success(:final data):
          _programmes = data;
        case Failure(:final message):
          _error = message;
      }
      switch (offersResult) {
        case Success(:final data):
          _offers = data.take(3).toList();
        case Failure(:final message):
          _error ??= message;
      }
    });
  }

  ProgrammeHighlight? get _recruiting {
    try {
      return _programmes.firstWhere((p) => p.isRecruiting);
    } catch (_) {
      return _programmes.isEmpty ? null : _programmes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recruiting = _recruiting;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const DemoBanner(
                  message:
                      'Home: programme CTA · best sellers · promotions. Then Training · Academies · Store.',
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Hi ${widget.user.name.split(' ').first},',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        AppConfig.demoModeLine,
                        style: const TextStyle(fontSize: 11),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                      ],
                      if (recruiting != null) ...[
                        const SizedBox(height: 12),
                        Material(
                          color: DigititanColors.primaryDark,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: widget.onOpenTraining,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Programme open',
                                    style: TextStyle(
                                      color: DigititanColors.teal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recruiting.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recruiting.subtitle,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: DigititanColors.accent,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(48, 40),
                                    ),
                                    onPressed: widget.onOpenTraining,
                                    child: const Text('Register interest now'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _sectionHeader('Best sellers', onSeeAll: widget.onOpenStore),
                      if (_bestSellers.isEmpty)
                        const Text('No best sellers flagged yet.')
                      else
                        ..._bestSellers.map(_productTile),
                      const SizedBox(height: 16),
                      _sectionHeader('Promotions', onSeeAll: widget.onOpenStore),
                      if (_promos.isEmpty)
                        const Text('No promotions flagged yet — Ops can toggle specials.')
                      else
                        ..._promos.map(_productTile),
                      const SizedBox(height: 16),
                      _sectionHeader('Featured training', onSeeAll: widget.onOpenTraining),
                      ..._offers.map(
                        (o) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(o.title),
                          subtitle: Text('${o.category} · ${o.level} · ${o.hours}h'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TrainingDetailScreen(
                                  container: widget.container,
                                  user: widget.user,
                                  trainingId: o.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }

  Widget _productTile(Product p) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(p.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.category),
          ProductPriceText(product: p, compact: true),
          if (p.onPromotion)
            const Text('Promo', style: TextStyle(fontSize: 12)),
        ],
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              container: widget.container,
              user: widget.user,
              productId: p.id,
            ),
          ),
        );
      },
    );
  }
}

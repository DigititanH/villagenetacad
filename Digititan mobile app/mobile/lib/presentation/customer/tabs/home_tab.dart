import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/programme_highlight.dart';
import '../../../domain/entities/training_offer.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/result/result.dart';
import '../../../shared/theme/digititan_theme.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../../shared/widgets/product_image.dart';
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
    final firstName = widget.user.name.split(' ').first;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Text(
                  'Hi $firstName',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Training · Academies · Store',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
                ],
                if (recruiting != null) ...[
                  const SizedBox(height: 18),
                  _ProgrammeHero(
                    title: recruiting.title,
                    subtitle: recruiting.subtitle,
                    onTap: widget.onOpenTraining,
                  ),
                ],
                SectionHeader(
                  title: 'Best sellers',
                  onAction: widget.onOpenStore,
                ),
                if (_bestSellers.isEmpty)
                  Text(
                    'No best sellers yet.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  ..._bestSellers.map(_productRow),
                SectionHeader(
                  title: 'Promotions',
                  onAction: widget.onOpenStore,
                ),
                if (_promos.isEmpty)
                  Text(
                    'No promotions right now.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  ..._promos.map(_productRow),
                SectionHeader(
                  title: 'Featured training',
                  onAction: widget.onOpenTraining,
                ),
                ..._offers.map(
                  (o) => _TrainingRow(
                    offer: o,
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
    );
  }

  Widget _productRow(Product p) {
    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            ProductImage(imageUrl: p.imageUrl, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(p.category, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 2),
                  ProductPriceText(product: p, compact: true),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: DigititanColors.primary),
          ],
        ),
      ),
    );
  }
}

class _ProgrammeHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProgrammeHero({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DigititanColors.primaryDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Now recruiting',
                style: TextStyle(
                  color: DigititanColors.teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onTap,
                child: const Text('Register interest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrainingRow extends StatelessWidget {
  final TrainingOffer offer;
  final VoidCallback onTap;

  const _TrainingRow({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(offer.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${offer.category} · ${offer.level} · ${offer.hours}h'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

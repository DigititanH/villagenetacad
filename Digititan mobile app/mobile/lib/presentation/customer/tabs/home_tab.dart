import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/academy.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/training_offer.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/result/result.dart';
import '../../../shared/theme/digititan_theme.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../../shared/widgets/product_price_text.dart';
import '../product_detail_screen.dart';
import '../training_detail_screen.dart';

/// Home keeps Training · Academies · Store as equal pillars (Phase 3).
class HomeTab extends StatefulWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onOpenTraining;
  final VoidCallback onOpenAcademies;
  final VoidCallback onOpenStore;

  const HomeTab({
    super.key,
    required this.container,
    required this.user,
    required this.onOpenTraining,
    required this.onOpenAcademies,
    required this.onOpenStore,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<TrainingOffer> _offers = [];
  List<Academy> _academies = [];
  List<Product> _products = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final offersResult = await widget.container.getTrainingOffers();
    final academiesResult = await widget.container.getAcademies();
    final productsResult = await widget.container.getProducts();
    if (!mounted) return;

    setState(() {
      _loading = false;
      switch (offersResult) {
        case Success(:final data):
          _offers = data.take(3).toList();
        case Failure(:final message):
          _error = message;
      }
      switch (academiesResult) {
        case Success(:final data):
          _academies = data.where((a) => a.isActive).take(3).toList();
          if (_academies.isEmpty) _academies = data.take(3).toList();
        case Failure(:final message):
          _error ??= message;
      }
      switch (productsResult) {
        case Success(:final data):
          final featured =
              data.where((p) => p.isBestSeller || p.onPromotion).toList();
          _products = (featured.isEmpty ? data : featured).take(3).toList();
        case Failure(:final message):
          _error ??= message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  'Village NetAcad · Training · Academies · Store',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
                ],
                const SizedBox(height: 18),
                _equalPillars(
                  context,
                  training: widget.onOpenTraining,
                  academies: widget.onOpenAcademies,
                  store: widget.onOpenStore,
                ),
                SectionHeader(
                  title: 'Training',
                  actionLabel: 'See all',
                  onAction: widget.onOpenTraining,
                ),
                if (_offers.isEmpty)
                  Text('No training offers yet.', style: Theme.of(context).textTheme.bodySmall)
                else
                  ..._offers.map(
                    (o) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(o.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${o.category} · ${o.level} · ${o.hours}h'),
                      trailing: const Icon(Icons.chevron_right),
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
                SectionHeader(
                  title: 'Academies',
                  actionLabel: 'See all',
                  onAction: widget.onOpenAcademies,
                ),
                if (_academies.isEmpty)
                  Text('No academies yet.', style: Theme.of(context).textTheme.bodySmall)
                else
                  ..._academies.map(
                    (a) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${a.province}${a.isActive ? '' : ' · Inactive'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: widget.onOpenAcademies,
                    ),
                  ),
                SectionHeader(
                  title: 'Store',
                  actionLabel: 'See all',
                  onAction: widget.onOpenStore,
                ),
                if (_products.isEmpty)
                  Text('No products yet.', style: Theme.of(context).textTheme.bodySmall)
                else
                  ..._products.map(_productRow),
              ],
            ),
    );
  }

  Widget _equalPillars(
    BuildContext context, {
    required VoidCallback training,
    required VoidCallback academies,
    required VoidCallback store,
  }) {
    return Row(
      children: [
        Expanded(
          child: _PillarChip(
            icon: Icons.school_outlined,
            label: 'Training',
            onTap: training,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PillarChip(
            icon: Icons.map_outlined,
            label: 'Academies',
            onTap: academies,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PillarChip(
            icon: Icons.storefront_outlined,
            label: 'Store',
            onTap: store,
          ),
        ),
      ],
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: p.onPromotion
                    ? DigititanColors.softGreen
                    : DigititanColors.softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                p.onPromotion ? Icons.local_offer_outlined : Icons.shopping_bag_outlined,
                color: DigititanColors.primary,
                size: 22,
              ),
            ),
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

class _PillarChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillarChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DigititanColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DigititanColors.muted),
          ),
          child: Column(
            children: [
              Icon(icon, color: DigititanColors.primary),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

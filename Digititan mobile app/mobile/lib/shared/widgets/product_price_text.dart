import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

String moneyZar(double amount) => 'R${amount.toStringAsFixed(0)}';

/// Sale-style price: ~~was~~ now when product is on promo with a higher compare-at.
class ProductPriceText extends StatelessWidget {
  final Product product;
  final TextStyle? style;
  final TextStyle? wasStyle;
  final bool compact;

  const ProductPriceText({
    super.key,
    required this.product,
    this.style,
    this.wasStyle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final muted = wasStyle ??
        base.copyWith(
          decoration: TextDecoration.lineThrough,
          color: (base.color ?? Theme.of(context).colorScheme.onSurface)
              .withValues(alpha: 0.55),
          fontWeight: FontWeight.w400,
        );

    if (!product.showsSalePrice) {
      return Text(moneyZar(product.price), style: base);
    }

    final gap = compact ? ' ' : '  ';
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: moneyZar(product.compareAtPrice!), style: muted),
          TextSpan(text: gap),
          TextSpan(text: moneyZar(product.price), style: base),
        ],
      ),
    );
  }
}

/// One-line subtitle helper: category · prices · badges
String productPriceSubtitle(
  Product p, {
  bool includeCategory = true,
  String? extra,
}) {
  final buf = StringBuffer();
  if (includeCategory) buf.write(p.category);
  if (p.showsSalePrice) {
    if (buf.isNotEmpty) buf.write(' · ');
    buf.write('${moneyZar(p.compareAtPrice!)} → ${moneyZar(p.price)}');
  } else {
    if (buf.isNotEmpty) buf.write(' · ');
    buf.write(moneyZar(p.price));
  }
  if (p.onPromotion) buf.write(' · Promo');
  if (extra != null && extra.isNotEmpty) buf.write(extra);
  return buf.toString();
}

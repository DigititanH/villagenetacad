class Product {
  final String id;
  final String name;
  final String category;
  final String summary;
  final double price;
  /// Previous / list price shown struck through when [onPromotion] and higher than [price].
  final double? compareAtPrice;
  final bool inStock;
  final bool isBestSeller;
  final bool onPromotion;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.summary,
    required this.price,
    this.compareAtPrice,
    this.inStock = true,
    this.isBestSeller = false,
    this.onPromotion = false,
  });

  bool get showsSalePrice =>
      onPromotion && compareAtPrice != null && compareAtPrice! > price;

  Product copyWith({
    double? price,
    double? compareAtPrice,
    bool clearCompareAtPrice = false,
    bool? inStock,
    bool? isBestSeller,
    bool? onPromotion,
  }) {
    return Product(
      id: id,
      name: name,
      category: category,
      summary: summary,
      price: price ?? this.price,
      compareAtPrice:
          clearCompareAtPrice ? null : (compareAtPrice ?? this.compareAtPrice),
      inStock: inStock ?? this.inStock,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      onPromotion: onPromotion ?? this.onPromotion,
    );
  }
}

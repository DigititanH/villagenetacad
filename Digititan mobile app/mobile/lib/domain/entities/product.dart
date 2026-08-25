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
  /// Absolute or site-relative image URL from MySQL.
  final String? imageUrl;
  final String? slug;
  final int stockCount;
  final List<String> sizes;
  final List<String> colors;

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
    this.imageUrl,
    this.slug,
    this.stockCount = 0,
    this.sizes = const [],
    this.colors = const [],
  });

  bool get showsSalePrice =>
      onPromotion && compareAtPrice != null && compareAtPrice! > price;

  bool get hasVariants => sizes.isNotEmpty || colors.isNotEmpty;

  Product copyWith({
    double? price,
    double? compareAtPrice,
    bool clearCompareAtPrice = false,
    bool? inStock,
    bool? isBestSeller,
    bool? onPromotion,
    String? imageUrl,
    String? slug,
    int? stockCount,
    List<String>? sizes,
    List<String>? colors,
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
      imageUrl: imageUrl ?? this.imageUrl,
      slug: slug ?? this.slug,
      stockCount: stockCount ?? this.stockCount,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
    );
  }
}

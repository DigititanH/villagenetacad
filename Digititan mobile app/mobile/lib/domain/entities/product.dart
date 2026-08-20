class Product {
  final String id;
  final String name;
  final String category;
  final String summary;
  final double price;
  final bool inStock;
  final bool isBestSeller;
  final bool onPromotion;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.summary,
    required this.price,
    this.inStock = true,
    this.isBestSeller = false,
    this.onPromotion = false,
  });
}

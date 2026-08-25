import '../entities/product.dart';
import '../entities/shop_order.dart';

class CartLine {
  final Product product;
  final int quantity;

  /// Live API cart row id (null for in-memory demo cart).
  final String? cartItemId;
  final String? size;
  final String? color;

  const CartLine({
    required this.product,
    required this.quantity,
    this.cartItemId,
    this.size,
    this.color,
  });

  double get lineTotal => product.price * quantity;
}

class WishlistItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String? imageUrl;
  final String? slug;

  const WishlistItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.slug,
  });
}

abstract class StoreRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProduct(String id);

  Future<List<CartLine>> getCart();
  Future<void> addToCart(
    Product product, {
    int quantity = 1,
    String? size,
    String? color,
  });
  Future<void> updateQuantity(CartLine line, int quantity);
  Future<void> clearCart();
  Future<double> cartTotal();

  /// True when checkout must open the website (Phase 5+ live path).
  bool get checkoutOnWebsite;

  Future<List<WishlistItem>> getWishlist();
  Future<bool> toggleWishlist(String productId);

  /// Prototype: creates order after OTP is confirmed (dummy only).
  Future<ShopOrder> placeOrder({
    required String buyerEmail,
    required String buyerName,
    String? referralCode,
  });

  Future<List<ShopOrder>> getOrdersFor(String email);
  Future<ShopOrder?> getOrder(String id);

  Future<void> updateProductPrice(String productId, double price);

  /// Phase 2: return within 7 days of delivery.
  Future<ShopOrder> requestReturn({
    required String orderId,
    required String reason,
  });

  /// Phase 2: review after delivered.
  Future<ShopOrder> submitReview({
    required String orderId,
    required int stars,
    required String text,
  });

  /// Payment OTP prototype helpers
  String startPaymentOtp(String email);
  bool verifyPaymentOtp(String email, String otp);
}

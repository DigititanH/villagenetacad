import '../entities/product.dart';
import '../entities/shop_order.dart';

class CartLine {
  final Product product;
  final int quantity;

  /// Live API cart row id (null for in-memory demo cart).
  final String? cartItemId;

  const CartLine({
    required this.product,
    required this.quantity,
    this.cartItemId,
  });

  double get lineTotal => product.price * quantity;
}

abstract class StoreRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProduct(String id);

  Future<List<CartLine>> getCart();
  Future<void> addToCart(Product product, {int quantity = 1});
  Future<void> updateQuantity(CartLine line, int quantity);
  Future<void> clearCart();
  Future<double> cartTotal();

  /// True when checkout must open the website (Phase 5 live path).
  bool get checkoutOnWebsite;

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

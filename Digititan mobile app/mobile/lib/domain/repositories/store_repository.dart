import '../entities/product.dart';
import '../entities/shop_order.dart';

class CartLine {
  final Product product;
  final int quantity;

  const CartLine({required this.product, required this.quantity});

  double get lineTotal => product.price * quantity;
}

abstract class StoreRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProduct(String id);

  List<CartLine> getCart();
  void addToCart(Product product, {int quantity = 1});
  void updateQuantity(String productId, int quantity);
  void clearCart();
  double cartTotal();

  /// Prototype: creates order after OTP is confirmed.
  Future<ShopOrder> placeOrder({
    required String buyerEmail,
    required String buyerName,
    String? referralCode,
  });

  Future<List<ShopOrder>> getOrdersFor(String email);
  Future<ShopOrder?> getOrder(String id);

  Future<void> updateProductPrice(String productId, double price);

  /// Payment OTP prototype helpers
  String startPaymentOtp(String email);
  bool verifyPaymentOtp(String email, String otp);
}

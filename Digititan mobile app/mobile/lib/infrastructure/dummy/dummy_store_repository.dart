import '../../domain/entities/product.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/repositories/store_repository.dart';

class DummyStoreRepository implements StoreRepository {
  final List<Product> _products = [
    const Product(
      id: 'p-laptop-bag',
      name: 'Digititan Laptop Bag',
      category: 'Accessories',
      summary: 'Durable bag for academy and work use.',
      price: 349,
      isBestSeller: true,
    ),
    const Product(
      id: 'p-headset',
      name: 'Support Headset',
      category: 'Hardware',
      summary: 'Entry-level headset for IT support training labs.',
      price: 499,
      onPromotion: true,
    ),
    const Product(
      id: 'p-network-kit',
      name: 'Home Lab Network Kit',
      category: 'Networking',
      summary: 'Starter cables and tools for networking practice.',
      price: 899,
      isBestSeller: true,
    ),
    const Product(
      id: 'p-hoodie',
      name: 'Village NetAcad Hoodie',
      category: 'Apparel',
      summary: 'Programme hoodie for beneficiaries and ambassadors.',
      price: 420,
      onPromotion: true,
    ),
    const Product(
      id: 'p-mouse',
      name: 'Wireless Mouse',
      category: 'Hardware',
      summary: 'Simple wireless mouse for digital literacy classes.',
      price: 199,
    ),
  ];

  final Map<String, int> _cart = {};
  final List<ShopOrder> _orders = [];
  final Map<String, String> _paymentOtps = {};

  @override
  Future<List<Product>> getProducts() async => List.unmodifiable(_products);

  @override
  Future<Product?> getProduct(String id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<CartLine> getCart() {
    final lines = <CartLine>[];
    for (final entry in _cart.entries) {
      final product = _products.firstWhere((p) => p.id == entry.key);
      lines.add(CartLine(product: product, quantity: entry.value));
    }
    return lines;
  }

  @override
  void addToCart(Product product, {int quantity = 1}) {
    _cart.update(product.id, (q) => q + quantity, ifAbsent: () => quantity);
  }

  @override
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      _cart.remove(productId);
    } else {
      _cart[productId] = quantity;
    }
  }

  @override
  void clearCart() => _cart.clear();

  @override
  double cartTotal() => getCart().fold(0, (sum, l) => sum + l.lineTotal);

  @override
  String startPaymentOtp(String email) {
    final key = email.trim().toLowerCase();
    _paymentOtps[key] = '654321'; // fixed prototype OTP
    // ignore: avoid_print
    print('PAYMENT OTP for $key = 654321');
    return _paymentOtps[key]!;
  }

  @override
  bool verifyPaymentOtp(String email, String otp) {
    final key = email.trim().toLowerCase();
    return _paymentOtps[key] == otp.trim();
  }

  @override
  Future<ShopOrder> placeOrder({
    required String buyerEmail,
    required String buyerName,
  }) async {
    final lines = getCart();
    if (lines.isEmpty) {
      throw Exception('Cart is empty');
    }

    final order = ShopOrder(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      buyerEmail: buyerEmail.trim().toLowerCase(),
      items: lines
          .map(
            (l) => OrderItem(
              productId: l.product.id,
              productName: l.product.name,
              quantity: l.quantity,
              unitPrice: l.product.price,
            ),
          )
          .toList(),
      status: OrderStatus.paid,
      createdAt: DateTime.now(),
      trackingTimeline: [
        'Order placed',
        'Payment confirmed (simulated gateway + OTP)',
        'Processing at Digititan Store',
      ],
    );
    _orders.insert(0, order);
    clearCart();
    _paymentOtps.remove(buyerEmail.trim().toLowerCase());
    // ignore: avoid_print
    print('ORDER PLACED: ${order.id} total=R${order.total} buyer=$buyerName');
    return order;
  }

  @override
  Future<List<ShopOrder>> getOrdersFor(String email) async {
    final key = email.trim().toLowerCase();
    return _orders.where((o) => o.buyerEmail == key).toList(growable: false);
  }

  @override
  Future<ShopOrder?> getOrder(String id) async {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateProductPrice(String productId, double price) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index < 0) throw Exception('Product not found');
    if (price <= 0) throw Exception('Price must be greater than 0');
    final old = _products[index];
    _products[index] = Product(
      id: old.id,
      name: old.name,
      category: old.category,
      summary: old.summary,
      price: price,
      inStock: old.inStock,
      isBestSeller: old.isBestSeller,
      onPromotion: old.onPromotion,
    );
    // ignore: avoid_print
    print('PRODUCT PRICE UPDATED: $productId -> R$price');
  }
}

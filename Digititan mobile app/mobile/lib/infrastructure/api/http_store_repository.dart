import '../../domain/entities/product.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/repositories/store_repository.dart';
import 'api_client.dart';

/// Live store: catalogue + server cart + my-orders (Phase 5).
/// Checkout / PayFast stay on the website.
class HttpStoreRepository implements StoreRepository {
  final ApiClient _api;

  HttpStoreRepository({required ApiClient api}) : _api = api;

  @override
  bool get checkoutOnWebsite => true;

  Product _mapProduct(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? 'Product';
    final category = json['category_name']?.toString() ??
        json['category']?.toString() ??
        'Store';
    final summary = (json['description'] ?? json['summary'] ?? '')
        .toString()
        .trim();
    final price = _asDouble(json['price']);
    final stock = json['stock'];
    final inStock = stock == null
        ? true
        : (stock is num ? stock > 0 : int.tryParse(stock.toString()) != 0);
    return Product(
      id: id,
      name: name,
      category: category,
      summary: summary.isEmpty ? name : summary,
      price: price,
      inStock: inStock,
      isBestSeller: json['is_bestseller'] == true || json['is_bestseller'] == 1,
      onPromotion: json['on_promotion'] == true || json['on_promotion'] == 1,
    );
  }

  double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  OrderStatus _mapStatus(String? raw, String? payment) {
    final s = (raw ?? '').toLowerCase();
    final pay = (payment ?? '').toLowerCase();
    if (s == 'delivered') return OrderStatus.delivered;
    if (s == 'shipped') return OrderStatus.shipped;
    if (s == 'cancelled') return OrderStatus.cancelled;
    if (s == 'processing') return OrderStatus.processing;
    if (pay == 'paid' || pay == 'complete' || pay == 'completed') {
      return OrderStatus.paid;
    }
    if (s == 'pending') return OrderStatus.placed;
    return OrderStatus.placed;
  }

  ShopOrder _mapOrder(Map<String, dynamic> json, {required String email}) {
    final itemsRaw = json['items'];
    final items = <OrderItem>[];
    if (itemsRaw is List) {
      for (final raw in itemsRaw) {
        if (raw is! Map) continue;
        final m = Map<String, dynamic>.from(raw);
        final qty = _asInt(m['quantity']);
        final price = _asDouble(m['price']);
        items.add(
          OrderItem(
            productId: m['product_id']?.toString() ?? '',
            productName: m['name']?.toString() ??
                'Item ${m['product_id'] ?? ''}',
            quantity: qty,
            unitPrice: price,
          ),
        );
      }
    }

    final created = DateTime.tryParse(json['created_at']?.toString() ?? '') ??
        DateTime.now();
    final status = _mapStatus(
      json['status']?.toString(),
      json['payment_status']?.toString(),
    );
    final total = _asDouble(json['total']);
    if (items.isEmpty && total > 0) {
      items.add(
        OrderItem(
          productId: 'order',
          productName: 'Order total',
          quantity: 1,
          unitPrice: total,
        ),
      );
    }

    return ShopOrder(
      id: 'ORD-${json['id']}',
      buyerEmail: email.trim().toLowerCase(),
      items: items,
      status: status,
      createdAt: created,
      trackingTimeline: [
        'Ordered ${created.toIso8601String().split('T').first}',
        'Payment: ${json['payment_status'] ?? 'pending'}',
        'Status: ${json['status'] ?? 'pending'}',
        if ((json['tracking_number']?.toString() ?? '').isNotEmpty)
          'Tracking: ${json['tracking_number']}',
        'Pay / track on villagenetacad.co.za',
      ],
      referralCode: json['referral_code']?.toString(),
    );
  }

  @override
  Future<List<Product>> getProducts() async {
    final json = await _api.getJson(
      '/api/products',
      auth: false,
      query: {'limit': '50', 'page': '1'},
    );
    final list = json['products'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => _mapProduct(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  @override
  Future<Product?> getProduct(String id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CartLine>> getCart() async {
    final rows = await _api.getList('/api/cart', auth: true);
    final lines = <CartLine>[];
    for (final raw in rows) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final product = Product(
        id: m['product_id']?.toString() ?? '',
        name: m['name']?.toString() ?? 'Product',
        category: 'Store',
        summary: m['name']?.toString() ?? '',
        price: _asDouble(m['price']),
        inStock: _asInt(m['stock']) > 0,
      );
      lines.add(
        CartLine(
          product: product,
          quantity: _asInt(m['quantity']),
          cartItemId: m['id']?.toString(),
        ),
      );
    }
    return lines;
  }

  @override
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final productId = int.tryParse(product.id);
    if (productId == null) {
      throw Exception('Invalid product id for live cart');
    }
    await _api.postJson(
      '/api/cart',
      {
        'product_id': productId,
        'quantity': quantity,
      },
      auth: true,
    );
  }

  @override
  Future<void> updateQuantity(CartLine line, int quantity) async {
    final cartId = line.cartItemId;
    if (cartId == null || cartId.isEmpty) {
      throw Exception('Missing cart item id');
    }
    if (quantity < 1) {
      await _api.deleteJson('/api/cart/$cartId', auth: true);
      return;
    }
    await _api.putJson(
      '/api/cart/$cartId',
      {'quantity': quantity},
      auth: true,
    );
  }

  @override
  Future<void> clearCart() async {
    await _api.deleteJson('/api/cart', auth: true);
  }

  @override
  Future<double> cartTotal() async {
    final lines = await getCart();
    return lines.fold<double>(0, (sum, l) => sum + l.lineTotal);
  }

  @override
  Future<ShopOrder> placeOrder({
    required String buyerEmail,
    required String buyerName,
    String? referralCode,
  }) async {
    throw Exception(
      'Pay on the Village NetAcad website (Phase 5). '
      'Open Cart → Complete on website.',
    );
  }

  @override
  Future<List<ShopOrder>> getOrdersFor(String email) async {
    final rows = await _api.getList('/api/orders/my-orders', auth: true);
    return rows
        .whereType<Map>()
        .map(
          (e) => _mapOrder(
            Map<String, dynamic>.from(e),
            email: email,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<ShopOrder?> getOrder(String id) async {
    final rawId = id.startsWith('ORD-') ? id.substring(4) : id;
    try {
      final json = await _api.getJson('/api/orders/$rawId', auth: true);
      // show() returns the order object directly as a map
      return _mapOrder(json, email: '');
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> updateProductPrice(String productId, double price) async {
    throw Exception('Change prices on the website admin (live API)');
  }

  @override
  Future<ShopOrder> requestReturn({
    required String orderId,
    required String reason,
  }) async {
    throw Exception('Returns on live orders land in a later phase');
  }

  @override
  Future<ShopOrder> submitReview({
    required String orderId,
    required int stars,
    required String text,
  }) async {
    throw Exception('Reviews on live orders land in a later phase');
  }

  @override
  String startPaymentOtp(String email) {
    throw Exception('Payment OTP is website PayFast in Phase 5');
  }

  @override
  bool verifyPaymentOtp(String email, String otp) => false;
}

import 'dart:convert';

import '../../domain/entities/product.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/repositories/store_repository.dart';
import '../../shared/utils/media_url.dart';
import '../dummy/demo_hub.dart';
import 'api_client.dart';

/// Live store: catalogue parity + server cart + wishlist + my-orders (Phase 5–6).
class HttpStoreRepository implements StoreRepository {
  final ApiClient _api;
  bool _sampleCatalogue = false;

  HttpStoreRepository({required ApiClient api}) : _api = api;

  @override
  bool get checkoutOnWebsite => true;

  bool get usingSampleCatalogue => _sampleCatalogue;

  List<String> _parseStringList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    final text = raw.toString().trim();
    if (text.isEmpty) return const [];
    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // comma-separated fallback
      return text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

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
    final compareAt = _asDouble(
      json['compare_price'] ?? json['compare_at_price'],
    );
    final stockCount = _asInt(json['stock']);
    final inStock = stockCount > 0;
    final sizes = _parseStringList(json['sizes']);
    final colors = _parseStringList(json['colors']);
    final onPromo = compareAt > price && compareAt > 0;
    return Product(
      id: id,
      name: name,
      category: category,
      summary: summary.isEmpty ? name : summary,
      price: price,
      compareAtPrice: onPromo ? compareAt : null,
      inStock: inStock,
      stockCount: stockCount,
      isBestSeller: json['is_bestseller'] == true ||
          json['is_bestseller'] == 1 ||
          json['is_featured'] == true ||
          json['is_featured'] == 1 ||
          (json['avg_rating'] != null && _asDouble(json['avg_rating']) >= 4.5),
      onPromotion: onPromo ||
          json['on_promotion'] == true ||
          json['on_promotion'] == 1,
      imageUrl: resolveMediaUrl(json['image']?.toString()),
      slug: json['slug']?.toString(),
      sizes: sizes,
      colors: colors,
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
    if (s == 'return_requested' || s == 'returnrequested') {
      return OrderStatus.returnRequested;
    }
    if (pay == 'paid' || pay == 'complete' || pay == 'completed') {
      return OrderStatus.paid;
    }
    return OrderStatus.placed;
  }

  List<String> _statusTimeline({
    required OrderStatus status,
    required String? payment,
    required String? tracking,
    required DateTime created,
  }) {
    final steps = <String>[
      'Placed · ${created.toIso8601String().split('T').first}',
    ];
    final pay = (payment ?? 'pending').toLowerCase();
    if (pay == 'paid' ||
        pay == 'complete' ||
        pay == 'completed' ||
        status.index >= OrderStatus.paid.index) {
      steps.add('Payment: paid');
    } else {
      steps.add('Payment: $pay');
    }

    const pipeline = [
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];
    for (final step in pipeline) {
      final label = switch (step) {
        OrderStatus.processing => 'Processing',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.delivered => 'Delivered',
        _ => step.name,
      };
      if (status == OrderStatus.cancelled) {
        break;
      }
      if (status.index >= step.index || status == OrderStatus.returnRequested) {
        steps.add('$label ✓');
      } else {
        steps.add('$label (pending)');
      }
    }
    if (status == OrderStatus.cancelled) {
      steps.add('Cancelled');
    }
    if (status == OrderStatus.returnRequested) {
      steps.add('Return requested');
    }
    if ((tracking ?? '').isNotEmpty) {
      steps.add('Tracking: $tracking');
    }
    return steps;
  }

  ShopOrder _mapOrder(Map<String, dynamic> json, {required String email}) {
    final itemsRaw = json['items'];
    final items = <OrderItem>[];
    if (itemsRaw is List) {
      for (final raw in itemsRaw) {
        if (raw is! Map) continue;
        final m = Map<String, dynamic>.from(raw);
        final size = m['size']?.toString();
        final color = m['color']?.toString();
        final baseName = m['name']?.toString() ?? 'Item ${m['product_id'] ?? ''}';
        final variant = [
          if (size != null && size.isNotEmpty) size,
          if (color != null && color.isNotEmpty) color,
        ].join(' · ');
        items.add(
          OrderItem(
            productId: m['product_id']?.toString() ?? '',
            productName: variant.isEmpty ? baseName : '$baseName ($variant)',
            quantity: _asInt(m['quantity']),
            unitPrice: _asDouble(m['price']),
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
      trackingTimeline: _statusTimeline(
        status: status,
        payment: json['payment_status']?.toString(),
        tracking: json['tracking_number']?.toString(),
        created: created,
      ),
      referralCode: json['referral_code']?.toString(),
      deliveredAt: status == OrderStatus.delivered ? created : null,
    );
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      final json = await _api.getJson(
        '/api/products',
        auth: false,
        query: {'limit': '50', 'page': '1'},
      );
      final list = json['products'];
      if (list is List && list.isNotEmpty) {
        _sampleCatalogue = false;
        return list
            .whereType<Map>()
            .map((e) => _mapProduct(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      }
    } catch (_) {}
    _sampleCatalogue = true;
    return List<Product>.unmodifiable(DemoHub.instance.products);
  }

  @override
  Future<Product?> getProduct(String id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((p) => p.id == id || p.slug == id);
    } catch (_) {
      return null;
    }
  }

  bool canAddToLiveCart(Product product) => int.tryParse(product.id) != null;

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
        stockCount: _asInt(m['stock']),
        imageUrl: resolveMediaUrl(m['image']?.toString()),
        sizes: _parseStringList(m['available_sizes']),
      );
      lines.add(
        CartLine(
          product: product,
          quantity: _asInt(m['quantity']),
          cartItemId: m['id']?.toString(),
          size: m['size']?.toString(),
          color: m['color']?.toString(),
        ),
      );
    }
    return lines;
  }

  @override
  Future<void> addToCart(
    Product product, {
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    final productId = int.tryParse(product.id);
    if (productId == null) {
      throw Exception(
        'This is a sample product. The live shop catalogue is empty — '
        'open Village NetAcad shop on the website to buy real items.',
      );
    }
    await _api.postJson(
      '/api/cart',
      {
        'product_id': productId,
        'quantity': quantity,
        if (size != null && size.isNotEmpty) 'size': size,
        if (color != null && color.isNotEmpty) 'color': color,
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

  final Set<String> _sampleWishlist = {};

  @override
  Future<List<WishlistItem>> getWishlist() async {
    if (_sampleCatalogue) {
      final items = <WishlistItem>[];
      for (final id in _sampleWishlist) {
        Product? p;
        try {
          p = DemoHub.instance.products.firstWhere((e) => e.id == id);
        } catch (_) {
          continue;
        }
        items.add(
          WishlistItem(
            id: id,
            productId: p.id,
            name: p.name,
            price: p.price,
            imageUrl: p.imageUrl,
            slug: p.slug,
          ),
        );
      }
      return items;
    }

    final rows = await _api.getList('/api/wishlist', auth: true);
    return rows.whereType<Map>().map((raw) {
      final m = Map<String, dynamic>.from(raw);
      return WishlistItem(
        id: m['id']?.toString() ?? '',
        productId: m['product_id']?.toString() ?? '',
        name: m['name']?.toString() ?? 'Product',
        price: _asDouble(m['price']),
        imageUrl: resolveMediaUrl(m['image']?.toString()),
        slug: m['slug']?.toString(),
      );
    }).toList(growable: false);
  }

  @override
  Future<bool> toggleWishlist(String productId) async {
    final id = int.tryParse(productId);
    if (id == null || _sampleCatalogue) {
      if (_sampleWishlist.contains(productId)) {
        _sampleWishlist.remove(productId);
        return false;
      }
      _sampleWishlist.add(productId);
      return true;
    }
    final json = await _api.postJson(
      '/api/wishlist/toggle',
      {'product_id': id},
      auth: true,
    );
    return json['wishlisted'] == true;
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
          (e) => _mapOrder(Map<String, dynamic>.from(e), email: email),
        )
        .toList(growable: false);
  }

  @override
  Future<ShopOrder?> getOrder(String id) async {
    final rawId = id.startsWith('ORD-') ? id.substring(4) : id;
    try {
      final json = await _api.getJson('/api/orders/$rawId', auth: true);
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

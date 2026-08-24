import '../../domain/entities/product.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/repositories/store_repository.dart';
import '../../shared/config/app_config.dart';
import 'demo_hub.dart';

class DummyStoreRepository implements StoreRepository {
  final _hub = DemoHub.instance;
  final Map<String, int> _cart = {};
  final Map<String, String> _paymentOtps = {};

  @override
  Future<List<Product>> getProducts() async =>
      List.unmodifiable(_hub.products);

  @override
  Future<Product?> getProduct(String id) async {
    try {
      return _hub.products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<CartLine> getCart() {
    final lines = <CartLine>[];
    for (final entry in _cart.entries) {
      final product = _hub.products.firstWhere((p) => p.id == entry.key);
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
    _paymentOtps[key] = '654321';
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
    String? referralCode,
  }) async {
    final lines = getCart();
    if (lines.isEmpty) throw Exception('Cart is empty');

    final codeRaw = (referralCode ??
            _hub.customerReferralCodes[buyerEmail.trim().toLowerCase()])
        ?.trim()
        .toUpperCase();
    final issued = codeRaw == null || codeRaw.isEmpty
        ? null
        : _hub.findCode(codeRaw);

    final items = lines
        .map(
          (l) => OrderItem(
            productId: l.product.id,
            productName: l.product.name,
            quantity: l.quantity,
            unitPrice: l.product.price,
          ),
        )
        .toList();

    final order = ShopOrder(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      buyerEmail: buyerEmail.trim().toLowerCase(),
      items: items,
      status: OrderStatus.paid,
      createdAt: DateTime.now(),
      trackingTimeline: [
        'Order placed',
        'Payment confirmed (simulated gateway + OTP)',
        if (issued != null)
          'Referral code ${issued.code} (${issued.type.label}) applied',
        'Processing at Digititan Store',
      ],
      referralCode: issued?.code,
    );

    _hub.orders.insert(0, order);
    if (issued != null) {
      _hub.customerReferralCodes[buyerEmail.trim().toLowerCase()] = issued.code;
      _hub.attributeSale(
        referralCode: issued.code,
        buyerName: buyerName,
        buyerEmail: buyerEmail,
        items: items,
        orderTotal: order.total,
      );
    }

    clearCart();
    _paymentOtps.remove(buyerEmail.trim().toLowerCase());
    _hub.log('Order ${order.id} placed R${order.total.toStringAsFixed(0)}');
    return order;
  }

  @override
  Future<List<ShopOrder>> getOrdersFor(String email) async {
    final key = email.trim().toLowerCase();
    return _hub.orders.where((o) => o.buyerEmail == key).toList(growable: false);
  }

  @override
  Future<ShopOrder?> getOrder(String id) async {
    try {
      return _hub.orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateProductPrice(String productId, double price) async {
    final index = _hub.products.indexWhere((p) => p.id == productId);
    if (index < 0) throw Exception('Product not found');
    if (price <= 0) throw Exception('Price must be greater than 0');
    final old = _hub.products[index];
    if (price < old.price) {
      final was = old.compareAtPrice != null && old.compareAtPrice! > old.price
          ? old.compareAtPrice
          : old.price;
      _hub.products[index] = old.copyWith(price: price, compareAtPrice: was);
    } else if (old.compareAtPrice != null && price >= old.compareAtPrice!) {
      _hub.products[index] = old.copyWith(price: price, clearCompareAtPrice: true);
    } else {
      _hub.products[index] = old.copyWith(price: price);
    }
  }

  @override
  Future<ShopOrder> requestReturn({
    required String orderId,
    required String reason,
  }) async {
    final index = _hub.orders.indexWhere((o) => o.id == orderId);
    if (index < 0) throw Exception('Order not found');
    final order = _hub.orders[index];
    if (!order.canRequestReturn) {
      throw Exception(
        'Return window closed or order not eligible '
        '(${AppConfig.returnWindowDays} days after delivery).',
      );
    }
    final updated = order.copyWith(
      status: OrderStatus.returnRequested,
      returnRequested: true,
      trackingTimeline: [
        ...order.trackingTimeline,
        'Return requested: $reason',
      ],
    );
    _hub.orders[index] = updated;
    _hub.notifications.insert(
      0,
      DemoNotification(
        id: 'n-ret-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Return requested',
        body: 'We received your return for $orderId.',
        recipientEmail: order.buyerEmail,
        createdAt: DateTime.now(),
      ),
    );
    _hub.log('Return requested $orderId: $reason');
    return updated;
  }

  @override
  Future<ShopOrder> submitReview({
    required String orderId,
    required int stars,
    required String text,
  }) async {
    final index = _hub.orders.indexWhere((o) => o.id == orderId);
    if (index < 0) throw Exception('Order not found');
    final order = _hub.orders[index];
    if (!order.canReview) {
      throw Exception('This order cannot be reviewed yet');
    }
    if (stars < 1 || stars > 5) {
      throw Exception('Choose 1 to 5 stars');
    }
    final updated = order.copyWith(
      reviewed: true,
      reviewStars: stars,
      reviewText: text.trim(),
      trackingTimeline: [
        ...order.trackingTimeline,
        'Review submitted ($stars★)',
      ],
    );
    _hub.orders[index] = updated;
    _hub.notifications.insert(
      0,
      DemoNotification(
        id: 'n-rev-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Thanks for your review',
        body: 'Your $stars★ review for $orderId was saved.',
        recipientEmail: order.buyerEmail,
        createdAt: DateTime.now(),
      ),
    );
    _hub.log('Review $orderId: $stars★ $text');
    return updated;
  }

  /// Validate + remember a referral code for this customer (prototype).
  String? saveReferralCode(String buyerEmail, String rawCode) {
    final issued = _hub.findCode(rawCode);
    if (issued == null) return null;
    _hub.customerReferralCodes[buyerEmail.trim().toLowerCase()] = issued.code;
    return issued.code;
  }
}

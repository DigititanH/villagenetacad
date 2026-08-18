import '../../domain/entities/product.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/repositories/store_repository.dart';

/// Admin ops backed partly by the shared store repo (orders/products).
class DummyAdminRepository implements AdminRepository {
  final StoreRepository storeRepository;

  final List<PendingResellerApplication> _pending = [
    PendingResellerApplication(
      id: 'pr-1',
      name: 'Kgomotso Mabena',
      email: 'kgomotso@example.com',
      academyName: 'Soweto Digital Hub',
      appliedAt: DateTime(2026, 8, 2),
    ),
    PendingResellerApplication(
      id: 'pr-2',
      name: 'Daniel Kruger',
      email: 'daniel@example.com',
      appliedAt: DateTime(2026, 8, 4),
    ),
    PendingResellerApplication(
      id: 'pr-3',
      name: 'Fatima Hassan',
      email: 'fatima@example.com',
      academyName: 'Cape Flats NetAcad Centre',
      appliedAt: DateTime(2026, 8, 6),
    ),
  ];

  final List<ShopOrder> _extraOrders = [
    ShopOrder(
      id: 'ORD-DEMO-1001',
      buyerEmail: 'aisha@example.com',
      items: const [
        OrderItem(
          productId: 'p-headset',
          productName: 'Support Headset',
          quantity: 1,
          unitPrice: 499,
        ),
      ],
      status: OrderStatus.processing,
      createdAt: DateTime(2026, 8, 5),
      trackingTimeline: const [
        'Order placed',
        'Payment confirmed',
        'Processing at Digititan Store',
      ],
    ),
    ShopOrder(
      id: 'ORD-DEMO-1002',
      buyerEmail: 'sipho@example.com',
      items: const [
        OrderItem(
          productId: 'p-hoodie',
          productName: 'Village NetAcad Hoodie',
          quantity: 2,
          unitPrice: 420,
        ),
      ],
      status: OrderStatus.placed,
      createdAt: DateTime(2026, 8, 12),
      trackingTimeline: const [
        'Order placed',
        'Awaiting payment confirmation',
      ],
    ),
  ];

  DummyAdminRepository(this.storeRepository);

  @override
  Future<AdminStats> getStats() async {
    final products = await storeRepository.getProducts();
    final allOrders = await getAllOrders();
    final pendingOrders =
        allOrders.where((o) => o.status == OrderStatus.placed || o.status == OrderStatus.processing).length;
    final revenue = allOrders.fold<double>(0, (sum, o) => sum + o.total);
    return AdminStats(
      totalUsers: 248,
      totalRevenue: revenue + 186450,
      totalOrders: allOrders.length + 130,
      pendingOrders: pendingOrders,
      pendingResellers: _pending.length,
      products: products.length,
    );
  }

  @override
  Future<List<ShopOrder>> getAllOrders() async {
    // Combine demo admin orders + any orders placed in this app session.
    // Store repo only exposes per-email get; for prototype we keep admin demo list
    // and also surface latest cart-placed orders if repository is DummyStoreRepository.
    return List.unmodifiable(_extraOrders);
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _extraOrders.indexWhere((o) => o.id == orderId);
    if (index < 0) throw Exception('Order not found');
    final old = _extraOrders[index];
    final timeline = [...old.trackingTimeline, 'Status updated to ${status.name}'];
    _extraOrders[index] = ShopOrder(
      id: old.id,
      buyerEmail: old.buyerEmail,
      items: old.items,
      status: status,
      createdAt: old.createdAt,
      trackingTimeline: timeline,
    );
    // ignore: avoid_print
    print('ADMIN ORDER UPDATE: $orderId -> ${status.name}');
  }

  @override
  Future<List<PendingResellerApplication>> getPendingResellers() async =>
      List.unmodifiable(_pending);

  @override
  Future<String> approveReseller(String applicationId) async {
    final app = _pending.firstWhere((p) => p.id == applicationId);
    _pending.removeWhere((p) => p.id == applicationId);
    final code = 'VNA-${app.name.split(' ').first.toUpperCase()}';
    // ignore: avoid_print
    print('RESELLER APPROVED: ${app.email} code=$code');
    return code;
  }

  @override
  Future<List<Product>> getProducts() => storeRepository.getProducts();

  @override
  Future<void> updateProductPrice(String productId, double price) {
    return storeRepository.updateProductPrice(productId, price);
  }
}

import '../entities/product.dart';
import '../entities/shop_order.dart';

class PendingResellerApplication {
  final String id;
  final String name;
  final String email;
  final String? academyName;
  final DateTime appliedAt;

  const PendingResellerApplication({
    required this.id,
    required this.name,
    required this.email,
    this.academyName,
    required this.appliedAt,
  });
}

class AdminStats {
  final int totalUsers;
  final double totalRevenue;
  final int totalOrders;
  final int pendingOrders;
  final int pendingResellers;
  final int products;

  const AdminStats({
    required this.totalUsers,
    required this.totalRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.pendingResellers,
    required this.products,
  });
}

abstract class AdminRepository {
  Future<AdminStats> getStats();
  Future<List<ShopOrder>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<List<PendingResellerApplication>> getPendingResellers();
  Future<String> approveReseller(String applicationId);
  Future<List<Product>> getProducts();
  Future<void> updateProductPrice(String productId, double price);
}

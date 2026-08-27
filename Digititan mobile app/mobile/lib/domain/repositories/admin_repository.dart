import '../entities/product.dart';
import '../entities/reseller.dart';
import '../entities/shop_order.dart';
import '../entities/withdrawal_request.dart';

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
  final int pendingAmbassadors;
  final int products;
  final int pendingWithdrawals;
  final int openLeads;

  const AdminStats({
    required this.totalUsers,
    required this.totalRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.pendingResellers,
    this.pendingAmbassadors = 0,
    required this.products,
    this.pendingWithdrawals = 0,
    this.openLeads = 0,
  });
}

abstract class AdminRepository {
  Future<AdminStats> getStats();
  Future<List<ShopOrder>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);

  Future<List<PendingResellerApplication>> getPendingResellers();
  /// Issues centre or beneficiary code and stores it on the reseller profile.
  Future<String> approveReseller(
    String applicationId, {
    required ResellerCodeType codeType,
  });
  Future<void> rejectReseller(String applicationId);

  /// Ambassador applications (Ops Admin queue). Optional status filter.
  Future<List<dynamic>> getAmbassadorApplications({String? status});
  Future<void> approveAmbassador(String applicationId);
  Future<void> rejectAmbassador(String applicationId);
  Future<void> deactivateAmbassador(String applicationId);
  Future<void> reactivateAmbassador(String applicationId);

  /// All reseller profiles (approved / pending / rejected / deactivated).
  Future<List<ResellerProfile>> getResellerProfiles();
  Future<void> deactivateReseller(String email);
  Future<void> reactivateReseller(String email);

  Future<List<Product>> getProducts();
  Future<void> updateProductPrice(String productId, double price);
  Future<Product> addProduct({
    required String name,
    required String category,
    required String summary,
    required double price,
  });
  Future<void> setProductStock(String productId, bool inStock);
  Future<void> setProductPromotion(String productId, bool onPromotion);

  Future<List<IssuedResellerCode>> getIssuedCodes();
  Future<List<WithdrawalRequest>> getPendingWithdrawals();
  Future<void> approveWithdrawal(String id);
  Future<void> rejectWithdrawal(String id);

  Future<List<dynamic>> getTrainingLeads();
  Future<List<dynamic>> getAcademyLeads();
  Future<List<dynamic>> getOrgApplications();
  Future<void> updateLeadStatus({
    required String leadId,
    required String queue, // training | academy | org
    required String status,
  });

  Future<List<String>> getActivityLog();
}

import '../../domain/entities/product.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/repositories/admin_repository.dart';
import 'demo_hub.dart';

class DummyAdminRepository implements AdminRepository {
  final _hub = DemoHub.instance;

  @override
  Future<AdminStats> getStats() async {
    final pendingOrders = _hub.orders
        .where((o) =>
            o.status == OrderStatus.placed ||
            o.status == OrderStatus.processing ||
            o.status == OrderStatus.paid)
        .length;
    final revenue = _hub.orders.fold<double>(0, (s, o) => s + o.total);
    final openLeads = _hub.trainingInterests.where((l) => l.status == 'new').length +
        _hub.academyInterests.where((l) => l.status == 'new').length +
        _hub.orgApplications.where((o) => o.status == 'pending').length;
    return AdminStats(
      totalUsers: 3 + _hub.resellerProfiles.length + _hub.customerReferralCodes.length,
      totalRevenue: revenue,
      totalOrders: _hub.orders.length,
      pendingOrders: pendingOrders,
      pendingResellers: _hub.pendingResellers.length,
      products: _hub.products.length,
      pendingWithdrawals:
          _hub.withdrawals.where((w) => w.status == 'pending').length,
      openLeads: openLeads,
    );
  }

  @override
  Future<List<ShopOrder>> getAllOrders() async =>
      List.unmodifiable(List.of(_hub.orders));

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final i = _hub.orders.indexWhere((o) => o.id == orderId);
    if (i < 0) throw Exception('Order not found');
    final old = _hub.orders[i];
    _hub.orders[i] = old.copyWith(
      status: status,
      trackingTimeline: [...old.trackingTimeline, 'Status → ${status.name}'],
    );
    _hub.log('Order $orderId → ${status.name}');
  }

  @override
  Future<List<PendingResellerApplication>> getPendingResellers() async =>
      List.unmodifiable(_hub.pendingResellers);

  @override
  Future<String> approveReseller(
    String applicationId, {
    required ResellerCodeType codeType,
  }) async {
    final app = _hub.pendingResellers.firstWhere((p) => p.id == applicationId);
    return _hub.issueCode(app: app, type: codeType);
  }

  @override
  Future<void> rejectReseller(String applicationId) async {
    _hub.pendingResellers.removeWhere((p) => p.id == applicationId);
    _hub.log('Reseller application $applicationId rejected');
  }

  @override
  Future<List<Product>> getProducts() async =>
      List.unmodifiable(_hub.products);

  @override
  Future<void> updateProductPrice(String productId, double price) async {
    final i = _hub.products.indexWhere((p) => p.id == productId);
    if (i < 0) throw Exception('Product not found');
    final p = _hub.products[i];
    _hub.products[i] = Product(
      id: p.id,
      name: p.name,
      category: p.category,
      summary: p.summary,
      price: price,
      inStock: p.inStock,
      isBestSeller: p.isBestSeller,
      onPromotion: p.onPromotion,
    );
    _hub.log('Product ${p.name} price → R${price.toStringAsFixed(0)}');
  }

  @override
  Future<Product> addProduct({
    required String name,
    required String category,
    required String summary,
    required double price,
  }) async {
    final product = Product(
      id: 'p-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      summary: summary,
      price: price,
    );
    _hub.products.add(product);
    _hub.log('Product added: ${product.name}');
    return product;
  }

  @override
  Future<void> setProductStock(String productId, bool inStock) async {
    final i = _hub.products.indexWhere((p) => p.id == productId);
    if (i < 0) throw Exception('Product not found');
    final p = _hub.products[i];
    _hub.products[i] = Product(
      id: p.id,
      name: p.name,
      category: p.category,
      summary: p.summary,
      price: p.price,
      inStock: inStock,
      isBestSeller: p.isBestSeller,
      onPromotion: p.onPromotion,
    );
  }

  @override
  Future<List<IssuedResellerCode>> getIssuedCodes() async =>
      List.unmodifiable(List.of(_hub.codesByValue.values));

  @override
  Future<List<WithdrawalRequest>> getPendingWithdrawals() async =>
      _hub.withdrawals.where((w) => w.status == 'pending').toList();

  @override
  Future<void> approveWithdrawal(String id) async {
    final w = _hub.withdrawals.firstWhere((x) => x.id == id);
    w.status = 'approved';
    _hub.log('Withdrawal approved ${w.resellerEmail} R${w.amount}');
  }

  @override
  Future<void> rejectWithdrawal(String id) async {
    final w = _hub.withdrawals.firstWhere((x) => x.id == id);
    w.status = 'rejected';
    final profile = _hub.resellerProfiles[w.resellerEmail];
    if (profile != null) {
      _hub.resellerProfiles[w.resellerEmail] =
          profile.copyWith(balance: profile.balance + w.amount);
    }
    _hub.log('Withdrawal rejected ${w.resellerEmail} — funds returned');
  }

  @override
  Future<List<InterestLead>> getTrainingLeads() async =>
      List.of(_hub.trainingInterests);

  @override
  Future<List<InterestLead>> getAcademyLeads() async =>
      List.of(_hub.academyInterests);

  @override
  Future<List<OrgApplication>> getOrgApplications() async =>
      List.of(_hub.orgApplications);

  @override
  Future<void> updateLeadStatus({
    required String leadId,
    required String queue,
    required String status,
  }) async {
    switch (queue) {
      case 'training':
        _hub.trainingInterests.firstWhere((l) => l.id == leadId).status = status;
      case 'academy':
        _hub.academyInterests.firstWhere((l) => l.id == leadId).status = status;
      case 'org':
        _hub.orgApplications.firstWhere((l) => l.id == leadId).status = status;
    }
    _hub.log('Lead $leadId ($queue) → $status');
  }

  @override
  Future<List<String>> getActivityLog() async => List.of(_hub.activityLog);
}

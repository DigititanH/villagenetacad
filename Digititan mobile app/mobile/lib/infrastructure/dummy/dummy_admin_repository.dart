import '../../domain/entities/product.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/entities/withdrawal_request.dart';
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
      pendingAmbassadors: _hub.ambassadorApplications
          .where((a) => a.status == 'under_review')
          .length,
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
    _hub.notifications.insert(
      0,
      DemoNotification(
        id: 'n-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Order update',
        body: 'Order $orderId is now: ${status.name}.',
        createdAt: DateTime.now(),
        recipientEmail: old.buyerEmail,
      ),
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
    final i = _hub.pendingResellers.indexWhere((p) => p.id == applicationId);
    if (i < 0) return;
    final app = _hub.pendingResellers.removeAt(i);
    final key = app.email.toLowerCase();
    final existing = _hub.resellerProfiles[key];
    if (existing != null) {
      _hub.resellerProfiles[key] = existing.copyWith(status: 'rejected');
    }
    _hub.log('Reseller application ${app.email} rejected');
  }

  @override
  Future<List<AmbassadorApplication>> getAmbassadorApplications({
    String? status,
  }) async {
    final all = List<AmbassadorApplication>.of(_hub.ambassadorApplications);
    if (status == null || status.isEmpty) return List.unmodifiable(all);
    return List.unmodifiable(all.where((a) => a.status == status));
  }

  @override
  Future<void> approveAmbassador(String applicationId) async {
    _hub.approveAmbassador(applicationId);
  }

  @override
  Future<void> rejectAmbassador(String applicationId) async {
    _hub.rejectAmbassador(applicationId);
  }

  @override
  Future<void> deactivateAmbassador(String applicationId) async {
    _hub.deactivateAmbassador(applicationId);
  }

  @override
  Future<void> reactivateAmbassador(String applicationId) async {
    _hub.reactivateAmbassador(applicationId);
  }

  @override
  Future<List<ResellerProfile>> getResellerProfiles() async =>
      List.unmodifiable(_hub.resellerProfiles.values.toList());

  @override
  Future<void> deactivateReseller(String email) async {
    _hub.deactivateReseller(email);
  }

  @override
  Future<void> reactivateReseller(String email) async {
    _hub.reactivateReseller(email);
  }

  @override
  Future<List<Product>> getProducts() async =>
      List.unmodifiable(_hub.products);

  @override
  Future<void> updateProductPrice(String productId, double price) async {
    final i = _hub.products.indexWhere((p) => p.id == productId);
    if (i < 0) throw Exception('Product not found');
    final p = _hub.products[i];
    _hub.products[i] = _withPriceChange(p, price);
    _hub.log(
      'Product ${p.name} price → R${price.toStringAsFixed(0)}'
      '${_hub.products[i].compareAtPrice != null ? ' (was R${_hub.products[i].compareAtPrice!.toStringAsFixed(0)})' : ''}',
    );
  }

  /// Dropping price keeps the previous amount as compare-at (strikethrough "was").
  Product _withPriceChange(Product p, double price) {
    if (price < p.price) {
      final was = p.compareAtPrice != null && p.compareAtPrice! > p.price
          ? p.compareAtPrice
          : p.price;
      return p.copyWith(price: price, compareAtPrice: was);
    }
    if (p.compareAtPrice != null && price >= p.compareAtPrice!) {
      return p.copyWith(price: price, clearCompareAtPrice: true);
    }
    return p.copyWith(price: price);
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
    _hub.products[i] = p.copyWith(inStock: inStock);
    _hub.log('Product ${p.name} stock → $inStock');
  }

  @override
  Future<void> setProductPromotion(String productId, bool onPromotion) async {
    final i = _hub.products.indexWhere((p) => p.id == productId);
    if (i < 0) throw Exception('Product not found');
    final p = _hub.products[i];
    _hub.products[i] = onPromotion
        ? p.copyWith(onPromotion: true)
        : p.copyWith(onPromotion: false, clearCompareAtPrice: true);
    _hub.log('Product ${p.name} promotion → $onPromotion');
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

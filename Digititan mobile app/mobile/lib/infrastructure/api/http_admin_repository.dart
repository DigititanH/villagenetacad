import '../../domain/entities/product.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/revenue_split.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/entities/withdrawal_request.dart';
import '../../domain/repositories/admin_repository.dart';
import 'api_client.dart';

/// Live Ops Admin APIs on villagenetacad.co.za.
///
/// No SMTP / email. Ambassadors, academy leads, and activity log are not on
/// the live API yet — those return empty / clear errors.
class HttpAdminRepository implements AdminRepository {
  final ApiClient _api;

  HttpAdminRepository({required ApiClient api}) : _api = api;

  @override
  Future<AdminStats> getStats() async {
    final json = await _api.getJson('/api/admin/dashboard', auth: true);
    final stats = json['stats'] is Map
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : <String, dynamic>{};

    var pendingWithdrawals = 0;
    try {
      final w = await getPendingWithdrawals();
      pendingWithdrawals = w.length;
    } catch (_) {}

    return AdminStats(
      totalUsers: _asInt(stats['total_users']),
      totalRevenue: _asDouble(stats['total_revenue']),
      totalOrders: _asInt(stats['total_orders']),
      pendingOrders: _asInt(stats['pending_orders']),
      pendingResellers: _asInt(stats['pending_resellers']),
      pendingAmbassadors: 0,
      products: _asInt(stats['total_products']),
      pendingWithdrawals: pendingWithdrawals,
      openLeads: 0,
    );
  }

  @override
  Future<List<ShopOrder>> getAllOrders() async {
    final json = await _api.getJson(
      '/api/orders/admin/all',
      auth: true,
      query: {'limit': '100', 'page': '1'},
    );
    final list = json['orders'];
    if (list is! List) return const [];
    return list.whereType<Map>().map((raw) {
      final m = Map<String, dynamic>.from(raw);
      final id = m['id']?.toString() ?? '';
      final total = _asDouble(m['total']);
      final created =
          DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now();
      final status = _mapOrderStatus(
        m['status']?.toString(),
        m['payment_status']?.toString(),
      );
      return ShopOrder(
        id: id,
        buyerEmail: m['customer_email']?.toString() ??
            m['customer_name']?.toString() ??
            'Customer',
        items: [
          OrderItem(
            productId: 'order',
            productName: 'Order #$id',
            quantity: 1,
            unitPrice: total,
          ),
        ],
        status: status,
        createdAt: created,
        trackingTimeline: [
          if (m['tracking_number'] != null)
            'Tracking: ${m['tracking_number']}',
          'Status: ${m['status']}',
          'Payment: ${m['payment_status']}',
        ],
        referralCode: m['referral_code']?.toString(),
        deliveredAt: status == OrderStatus.delivered ? created : null,
      );
    }).toList();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final apiStatus = _orderStatusToApi(status);
    if (apiStatus == null) {
      throw Exception(
        'Live orders only support: pending, processing, shipped, delivered, cancelled',
      );
    }
    await _api.putJson(
      '/api/orders/$orderId',
      {'status': apiStatus},
      auth: true,
    );
  }

  @override
  Future<List<PendingResellerApplication>> getPendingResellers() async {
    final all = await _resellerRows();
    return all
        .where((m) => (m['status']?.toString() ?? '') == 'pending')
        .map(_mapPending)
        .toList();
  }

  @override
  Future<String> approveReseller(
    String applicationId, {
    required ResellerCodeType codeType,
  }) async {
    // Live codes are already issued at register — approve only unlocks login.
    await _api.putJson(
      '/api/resellers/admin/$applicationId/status',
      {'status': 'approved'},
      auth: true,
    );
    final rows = await _resellerRows();
    for (final m in rows) {
      if (m['id']?.toString() == applicationId) {
        return m['referral_code']?.toString() ?? 'APPROVED';
      }
    }
    return 'APPROVED';
  }

  @override
  Future<void> rejectReseller(String applicationId) async {
    await _api.putJson(
      '/api/resellers/admin/$applicationId/status',
      {'status': 'rejected'},
      auth: true,
    );
  }

  @override
  Future<List<dynamic>> getAmbassadorApplications({String? status}) async {
    // No live ambassador admin API yet.
    return const [];
  }

  @override
  Future<void> approveAmbassador(String applicationId) async {
    throw Exception('Ambassador queue is not on the live API yet');
  }

  @override
  Future<void> rejectAmbassador(String applicationId) async {
    throw Exception('Ambassador queue is not on the live API yet');
  }

  @override
  Future<void> deactivateAmbassador(String applicationId) async {
    throw Exception('Ambassador queue is not on the live API yet');
  }

  @override
  Future<void> reactivateAmbassador(String applicationId) async {
    throw Exception('Ambassador queue is not on the live API yet');
  }

  @override
  Future<List<ResellerProfile>> getResellerProfiles() async {
    final rows = await _resellerRows();
    return rows.map(_mapProfile).toList();
  }

  @override
  Future<void> deactivateReseller(String email) async {
    final id = await _resellerIdByEmail(email);
    await _api.putJson(
      '/api/resellers/admin/$id/status',
      {'status': 'suspended'},
      auth: true,
    );
  }

  @override
  Future<void> reactivateReseller(String email) async {
    final id = await _resellerIdByEmail(email);
    await _api.putJson(
      '/api/resellers/admin/$id/status',
      {'status': 'approved'},
      auth: true,
    );
  }

  @override
  Future<List<Product>> getProducts() async {
    final json = await _api.getJson(
      '/api/products',
      auth: false,
      query: {'limit': '100', 'page': '1'},
    );
    final list = json['products'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => _mapProduct(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> updateProductPrice(String productId, double price) async {
    final products = await getProducts();
    Product? current;
    for (final p in products) {
      if (p.id == productId) {
        current = p;
        break;
      }
    }
    final body = <String, dynamic>{'price': price};
    if (current != null && price < current.price) {
      body['compare_price'] = current.compareAtPrice != null &&
              current.compareAtPrice! > current.price
          ? current.compareAtPrice
          : current.price;
    } else if (current != null &&
        current.compareAtPrice != null &&
        price >= current.compareAtPrice!) {
      body['compare_price'] = null;
    }
    await _api.putJson('/api/products/$productId', body, auth: true);
  }

  @override
  Future<Product> addProduct({
    required String name,
    required String category,
    required String summary,
    required double price,
  }) async {
    final created = await _api.postJson(
      '/api/products',
      {
        'name': name,
        'description': summary,
        'price': price,
        'stock': 10,
      },
      auth: true,
    );
    final id = created['id']?.toString() ?? '';
    return Product(
      id: id,
      name: name,
      category: category,
      summary: summary,
      price: price,
      inStock: true,
      stockCount: 10,
    );
  }

  @override
  Future<void> setProductStock(String productId, bool inStock) async {
    await _api.putJson(
      '/api/products/$productId',
      {'stock': inStock ? 10 : 0},
      auth: true,
    );
  }

  @override
  Future<void> setProductPromotion(String productId, bool onPromotion) async {
    if (!onPromotion) {
      await _api.putJson(
        '/api/products/$productId',
        {'compare_price': null},
        auth: true,
      );
      return;
    }
    // Promo prices are set via updateProductPrice (was/now) in the UI.
  }

  @override
  Future<List<IssuedResellerCode>> getIssuedCodes() async {
    final profiles = await getResellerProfiles();
    return profiles
        .where((p) => p.code.trim().isNotEmpty && p.code != 'PENDING')
        .map(
          (p) => IssuedResellerCode(
            code: p.code,
            type: p.codeType,
            resellerEmail: p.email,
            resellerName: p.name,
            academyName: p.academyName,
            issuedAt: DateTime.now(),
            active: p.isApproved,
          ),
        )
        .toList();
  }

  @override
  Future<List<WithdrawalRequest>> getPendingWithdrawals() async {
    final list =
        await _api.getList('/api/resellers/admin/withdrawals', auth: true);
    return list.whereType<Map>().map((raw) {
      final m = Map<String, dynamic>.from(raw);
      return WithdrawalRequest(
        id: m['id']?.toString() ?? '',
        resellerEmail: m['email']?.toString() ?? '',
        resellerName: m['name']?.toString() ?? 'Reseller',
        amount: _asDouble(m['amount']),
        createdAt: DateTime.tryParse(m['created_at']?.toString() ?? '') ??
            DateTime.now(),
        status: m['status']?.toString() ?? 'pending',
      );
    }).where((w) => w.status == 'pending').toList();
  }

  @override
  Future<void> approveWithdrawal(String id) async {
    await _api.putJson(
      '/api/resellers/admin/withdrawals/$id',
      {'status': 'approved'},
      auth: true,
    );
  }

  @override
  Future<void> rejectWithdrawal(String id) async {
    await _api.putJson(
      '/api/resellers/admin/withdrawals/$id',
      {'status': 'rejected'},
      auth: true,
    );
  }

  @override
  Future<List<dynamic>> getTrainingLeads() async => const [];

  @override
  Future<List<dynamic>> getAcademyLeads() async => const [];

  @override
  Future<List<dynamic>> getOrgApplications() async => const [];

  @override
  Future<void> updateLeadStatus({
    required String leadId,
    required String queue,
    required String status,
  }) async {
    throw Exception('Lead queues are not on the live API yet');
  }

  @override
  Future<List<String>> getActivityLog() async {
    return const [
      'Live mode: activity log stays on the website admin for now.',
    ];
  }

  Future<List<Map<String, dynamic>>> _resellerRows() async {
    final list = await _api.getList('/api/resellers/admin/all', auth: true);
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<String> _resellerIdByEmail(String email) async {
    final key = email.trim().toLowerCase();
    final rows = await _resellerRows();
    for (final m in rows) {
      if ((m['email']?.toString() ?? '').toLowerCase() == key) {
        return m['id']?.toString() ?? '';
      }
    }
    throw Exception('Reseller not found');
  }

  PendingResellerApplication _mapPending(Map<String, dynamic> m) {
    return PendingResellerApplication(
      id: m['id']?.toString() ?? '',
      name: m['name']?.toString() ?? 'Reseller',
      email: m['email']?.toString() ?? '',
      academyName: m['academy']?.toString(),
      appliedAt: DateTime.tryParse(m['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  ResellerProfile _mapProfile(Map<String, dynamic> m) {
    final code = m['referral_code']?.toString() ?? 'PENDING';
    return ResellerProfile(
      email: m['email']?.toString() ?? '',
      name: m['name']?.toString() ?? 'Reseller',
      code: code,
      codeType: _codeTypeFrom(code),
      status: _mapResellerStatus(m['status']?.toString()),
      totalEarned: _asDouble(m['total_earned']),
      balance: _asDouble(m['wallet_balance']),
      amountDueToDigititan: 0,
      centreShareTotal: 0,
      commissionRate: _asDouble(m['commission_rate']) == 0
          ? RevenueSplit.beneficiaryPercent
          : _asDouble(m['commission_rate']),
      academyName: m['academy']?.toString(),
    );
  }

  Product _mapProduct(Map<String, dynamic> json) {
    final price = _asDouble(json['price']);
    final compareAt = _asDouble(json['compare_price']);
    final stock = _asInt(json['stock']);
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Product',
      category: json['category_name']?.toString() ?? 'Store',
      summary: (json['description'] ?? '').toString(),
      price: price,
      compareAtPrice: compareAt > price ? compareAt : null,
      inStock: stock > 0,
      stockCount: stock,
      onPromotion: compareAt > price,
      imageUrl: json['image']?.toString(),
      slug: json['slug']?.toString(),
    );
  }

  OrderStatus _mapOrderStatus(String? raw, String? payment) {
    final s = (raw ?? '').toLowerCase();
    final pay = (payment ?? '').toLowerCase();
    if (s == 'delivered') return OrderStatus.delivered;
    if (s == 'shipped') return OrderStatus.shipped;
    if (s == 'cancelled') return OrderStatus.cancelled;
    if (s == 'processing') return OrderStatus.processing;
    if (pay == 'paid' || pay == 'complete' || pay == 'completed') {
      return OrderStatus.paid;
    }
    return OrderStatus.placed;
  }

  String? _orderStatusToApi(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'pending';
      case OrderStatus.paid:
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.returnRequested:
        return null;
    }
  }

  String _mapResellerStatus(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'approved':
        return 'approved';
      case 'rejected':
      case 'declined':
        return 'rejected';
      case 'suspended':
        return 'deactivated';
      default:
        return 'pending';
    }
  }

  ResellerCodeType _codeTypeFrom(String code) {
    final upper = code.trim().toUpperCase();
    if (upper.startsWith('VNA-C-')) return ResellerCodeType.centre;
    if (upper.startsWith('VNA-B-')) return ResellerCodeType.beneficiary;
    return ResellerCodeType.beneficiary;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0;
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim()) ?? 0;
  }
}

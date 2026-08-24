import '../../domain/entities/product.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/revenue_split.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/repositories/admin_repository.dart';

/// Shared in-memory demo state so Customer / Reseller / Admin flows connect.
class DemoHub {
  DemoHub._() {
    _seed();
  }
  static final DemoHub instance = DemoHub._();

  final List<Product> products = [];
  final List<ShopOrder> orders = [];
  final List<PendingResellerApplication> pendingResellers = [];
  final Map<String, ResellerProfile> resellerProfiles = {};
  final Map<String, List<ResellerClient>> resellerClients = {};
  final Map<String, List<ResellerSale>> resellerSales = {};
  final Map<String, IssuedResellerCode> codesByValue = {};
  final List<WithdrawalRequest> withdrawals = [];
  final List<InterestLead> trainingInterests = [];
  final List<InterestLead> academyInterests = [];
  final List<OrgApplication> orgApplications = [];
  final List<String> activityLog = [];

  /// Customer email -> last used / saved referral code
  final Map<String, String> customerReferralCodes = {};

  void _seed() {
    products.addAll([
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
        price: 399,
        compareAtPrice: 499,
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
        price: 349,
        compareAtPrice: 420,
        onPromotion: true,
      ),
      const Product(
        id: 'p-mouse',
        name: 'Wireless Mouse',
        category: 'Hardware',
        summary: 'Simple wireless mouse for digital literacy classes.',
        price: 199,
      ),
    ]);

    pendingResellers.addAll([
      PendingResellerApplication(
        id: 'ra-1',
        name: 'Kgomotso Molefe',
        email: 'kgomotso@example.com',
        academyName: 'Lesedi Labatu Academy',
        appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PendingResellerApplication(
        id: 'ra-2',
        name: 'Thabo Nkosi',
        email: 'thabo@example.com',
        appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PendingResellerApplication(
        id: 'ra-3',
        name: 'Fatima Hassan',
        email: 'fatima@example.com',
        academyName: 'Cape Flats NetAcad Centre',
        appliedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ]);

    // Seed demo reseller (login: reseller@demo.com)
    final seedCode = IssuedResellerCode(
      code: 'VNA-B-LERATO',
      type: ResellerCodeType.beneficiary,
      resellerEmail: 'reseller@demo.com',
      resellerName: 'Demo Reseller',
      academyName: 'Lesedi Labatu Academy',
      issuedAt: DateTime(2026, 7, 1),
    );
    codesByValue[seedCode.code] = seedCode;
    resellerProfiles['reseller@demo.com'] = ResellerProfile(
      email: 'reseller@demo.com',
      name: 'Demo Reseller',
      code: seedCode.code,
      codeType: ResellerCodeType.beneficiary,
      status: 'approved',
      totalEarned: 476.47, // ~53% of R899 seeded sale
      balance: 476.47,
      amountDueToDigititan: 188.79, // ~21% of R899
      centreShareTotal: 233.74, // ~26% of R899
      commissionRate: RevenueSplit.beneficiaryPercent,
      academyName: 'Lesedi Labatu Academy',
    );
    resellerClients['reseller@demo.com'] = [
      ResellerClient(
        id: 'c1',
        name: 'Nomsa Dlamini',
        email: 'nomsa@example.com',
        status: ResellerClientStatus.bought,
        productInterest: 'Home Lab Network Kit',
        updatedAt: DateTime(2026, 8, 1),
      ),
      ResellerClient(
        id: 'c2',
        name: 'Johan Botha',
        email: 'johan@example.com',
        status: ResellerClientStatus.confirmed,
        productInterest: 'Support Headset',
        updatedAt: DateTime(2026, 8, 10),
      ),
      ResellerClient(
        id: 'c3',
        name: 'Palesa Molefe',
        email: 'palesa@example.com',
        status: ResellerClientStatus.pending,
        productInterest: 'Village NetAcad Hoodie',
        updatedAt: DateTime(2026, 8, 14),
      ),
    ];
    resellerSales['reseller@demo.com'] = [
      ResellerSale(
        id: 's1',
        clientName: 'Nomsa Dlamini',
        productName: 'Home Lab Network Kit',
        amount: 899,
        commission: RevenueSplit.beneficiaryShare(899),
        date: DateTime(2026, 8, 1),
        referralCode: seedCode.code,
      ),
    ];

    orders.addAll([
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
        referralCode: null,
      ),
    ]);

    log('Demo hub ready (reseller code VNA-B-LERATO seeded)');
  }

  void log(String message) {
    final line =
        '${DateTime.now().toIso8601String().substring(11, 19)}  $message';
    activityLog.insert(0, line);
    if (activityLog.length > 100) activityLog.removeLast();
    // ignore: avoid_print
    print('DEMO: $message');
  }

  IssuedResellerCode? findCode(String raw) {
    final code = raw.trim().toUpperCase();
    if (code.isEmpty) return null;
    final hit = codesByValue[code];
    if (hit == null || !hit.active) return null;
    return hit;
  }

  /// Apply → pending. Admin must approve before a real VNA-C/VNA-B code exists.
  void applyReseller({
    required String name,
    required String email,
    String? academyName,
  }) {
    final key = email.trim().toLowerCase();
    if (resellerProfiles[key]?.status == 'approved') {
      throw Exception('This email is already an approved reseller');
    }
    final alreadyPending = pendingResellers.any((p) => p.email.toLowerCase() == key);
    if (alreadyPending) return;

    pendingResellers.insert(
      0,
      PendingResellerApplication(
        id: 'ra-${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        email: key,
        academyName: academyName?.trim().isEmpty == true ? null : academyName?.trim(),
        appliedAt: DateTime.now(),
      ),
    );
    resellerProfiles[key] = ResellerProfile(
      email: key,
      name: name.trim(),
      code: 'PENDING',
      codeType: ResellerCodeType.beneficiary,
      status: 'pending',
      totalEarned: 0,
      balance: 0,
      amountDueToDigititan: 0,
      centreShareTotal: 0,
      commissionRate: RevenueSplit.beneficiaryPercent,
      academyName: academyName?.trim().isEmpty == true ? null : academyName?.trim(),
    );
    resellerClients.putIfAbsent(key, () => []);
    resellerSales.putIfAbsent(key, () => []);
    log('Reseller application: $key (awaiting Ops Admin approval)');
  }

  ResellerClient addClient({
    required String resellerEmail,
    required String name,
    required String email,
    String? productInterest,
    ResellerClientStatus status = ResellerClientStatus.pending,
  }) {
    final key = resellerEmail.trim().toLowerCase();
    final profile = resellerProfiles[key];
    if (profile == null || !profile.isApproved) {
      throw Exception('Reseller must be approved before managing clients');
    }
    resellerClients.putIfAbsent(key, () => []);
    final client = ResellerClient(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      status: status,
      productInterest: productInterest?.trim().isEmpty == true
          ? null
          : productInterest?.trim(),
      updatedAt: DateTime.now(),
    );
    resellerClients[key]!.insert(0, client);
    log('Reseller $key added client ${client.email} (${status.name})');
    return client;
  }

  void updateClientStatus({
    required String resellerEmail,
    required String clientId,
    required ResellerClientStatus status,
  }) {
    final key = resellerEmail.trim().toLowerCase();
    final profile = resellerProfiles[key];
    if (profile == null || !profile.isApproved) {
      throw Exception('Reseller must be approved before managing clients');
    }
    final list = resellerClients[key];
    if (list == null) throw Exception('Client not found');
    final i = list.indexWhere((c) => c.id == clientId);
    if (i < 0) throw Exception('Client not found');
    final old = list[i];
    list[i] = ResellerClient(
      id: old.id,
      name: old.name,
      email: old.email,
      status: status,
      productInterest: old.productInterest,
      updatedAt: DateTime.now(),
    );
    log('Reseller $key client ${old.email} → ${status.name}');
  }

  String issueCode({
    required PendingResellerApplication app,
    required ResellerCodeType type,
  }) {
    final token = app.name.split(' ').first.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    var code = '${type.prefix}-$token';
    var n = 2;
    while (codesByValue.containsKey(code)) {
      code = '${type.prefix}-$token$n';
      n++;
    }
    final issued = IssuedResellerCode(
      code: code,
      type: type,
      resellerEmail: app.email.toLowerCase(),
      resellerName: app.name,
      academyName: app.academyName,
      issuedAt: DateTime.now(),
    );
    codesByValue[code] = issued;
    final sellerRate = type == ResellerCodeType.centre
        ? RevenueSplit.centrePercent
        : RevenueSplit.beneficiaryPercent;
    resellerProfiles[app.email.toLowerCase()] = ResellerProfile(
      email: app.email.toLowerCase(),
      name: app.name,
      code: code,
      codeType: type,
      status: 'approved',
      totalEarned: 0,
      balance: 0,
      amountDueToDigititan: 0,
      centreShareTotal: 0,
      commissionRate: sellerRate,
      academyName: app.academyName,
    );
    resellerClients.putIfAbsent(app.email.toLowerCase(), () => []);
    resellerSales.putIfAbsent(app.email.toLowerCase(), () => []);
    pendingResellers.removeWhere((p) => p.id == app.id);
    log('Reseller approved ${app.email} → $code (${type.label})');
    return code;
  }

  void attributeSale({
    required String referralCode,
    required String buyerName,
    required String buyerEmail,
    required List<OrderItem> items,
    required double orderTotal,
  }) {
    final issued = findCode(referralCode);
    if (issued == null) return;
    final email = issued.resellerEmail;
    final profile = resellerProfiles[email];
    if (profile == null) return;

    final digititanCut = RevenueSplit.digititanShare(orderTotal);
    final centreCut = RevenueSplit.centreShare(orderTotal);
    final beneficiaryCut = RevenueSplit.beneficiaryShare(orderTotal);

    // Centre codes earn the Centre 26% slice; Beneficiary codes earn 53%.
    final sellerCut = issued.type == ResellerCodeType.centre
        ? centreCut
        : beneficiaryCut;

    final productNames = items.map((i) => i.productName).join(', ');

    resellerSales.putIfAbsent(email, () => []);
    resellerSales[email]!.insert(
      0,
      ResellerSale(
        id: 's-${DateTime.now().millisecondsSinceEpoch}',
        clientName: buyerName,
        productName: productNames,
        amount: orderTotal,
        commission: sellerCut,
        date: DateTime.now(),
        referralCode: issued.code,
      ),
    );

    resellerClients.putIfAbsent(email, () => []);
    final clients = resellerClients[email]!;
    final existing = clients.indexWhere((c) => c.email == buyerEmail.toLowerCase());
    final client = ResellerClient(
      id: existing >= 0 ? clients[existing].id : 'c-${DateTime.now().millisecondsSinceEpoch}',
      name: buyerName,
      email: buyerEmail.toLowerCase(),
      status: ResellerClientStatus.bought,
      productInterest: productNames,
      updatedAt: DateTime.now(),
    );
    if (existing >= 0) {
      clients[existing] = client;
    } else {
      clients.insert(0, client);
    }

    resellerProfiles[email] = profile.copyWith(
      totalEarned: profile.totalEarned + sellerCut,
      balance: profile.balance + sellerCut,
      amountDueToDigititan: profile.amountDueToDigititan + digititanCut,
      centreShareTotal: profile.centreShareTotal + centreCut,
      commissionRate: issued.type == ResellerCodeType.centre
          ? RevenueSplit.centrePercent
          : RevenueSplit.beneficiaryPercent,
    );
    log(
      'Sale ${issued.code}: R${orderTotal.toStringAsFixed(0)} → '
      'seller R${sellerCut.toStringAsFixed(2)} · '
      'centre R${centreCut.toStringAsFixed(2)} · '
      'Digititan R${digititanCut.toStringAsFixed(2)}',
    );
  }
}

class InterestLead {
  final String id;
  final String subjectId;
  final String subjectTitle;
  final String fullName;
  final String email;
  final String phone;
  /// Meeting feedback: LMS alignment (full name, gender, email).
  final String gender;
  final String notes;
  final DateTime createdAt;
  String status;

  InterestLead({
    required this.id,
    required this.subjectId,
    required this.subjectTitle,
    required this.fullName,
    required this.email,
    required this.phone,
    this.gender = '',
    required this.notes,
    required this.createdAt,
    this.status = 'new',
  });
}

class OrgApplication {
  final String id;
  final String organisationName;
  final String contactName;
  final String email;
  final String phone;
  final String province;
  final DateTime createdAt;
  String status;

  OrgApplication({
    required this.id,
    required this.organisationName,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.province,
    required this.createdAt,
    this.status = 'pending',
  });
}

class WithdrawalRequest {
  final String id;
  final String resellerEmail;
  final String resellerName;
  final double amount;
  final DateTime createdAt;
  String status;

  WithdrawalRequest({
    required this.id,
    required this.resellerEmail,
    required this.resellerName,
    required this.amount,
    required this.createdAt,
    this.status = 'pending',
  });
}

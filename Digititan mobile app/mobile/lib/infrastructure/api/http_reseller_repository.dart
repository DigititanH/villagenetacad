import '../../domain/entities/reseller.dart';
import '../../domain/entities/revenue_split.dart';
import '../../domain/repositories/reseller_repository.dart';
import '../../shared/config/app_config.dart';
import 'api_client.dart';

/// Live reseller APIs on villagenetacad.co.za.
class HttpResellerRepository implements ResellerRepository {
  final ApiClient _api;

  HttpResellerRepository({required ApiClient api}) : _api = api;

  @override
  Future<ResellerProfile> getProfile(String email) async {
    final json = await _api.getJson('/api/resellers/profile', auth: true);
    return _mapProfile(json, fallbackEmail: email);
  }

  @override
  Future<void> applyToBecomeReseller({
    required String name,
    required String email,
    String? academyName,
  }) async {
    throw Exception(
      'Apply as reseller when creating your account (role: reseller), '
      'same as the website. Ops Admin must approve you.',
    );
  }

  @override
  Future<List<ResellerClient>> getClients(String email) async {
    final list = await _api.getList('/api/resellers/clients', auth: true);
    return list.whereType<Map>().map((raw) {
      final m = Map<String, dynamic>.from(raw);
      return ResellerClient(
        id: m['id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        email: m['email']?.toString() ?? '',
        status: _mapClientStatus(m['status']?.toString()),
        productInterest: m['product_interest']?.toString(),
        updatedAt: DateTime.tryParse(m['updated_at']?.toString() ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<ResellerClient> addClient({
    required String resellerEmail,
    required String name,
    required String email,
    String? productInterest,
    ResellerClientStatus status = ResellerClientStatus.pending,
  }) async {
    final json = await _api.postJson(
      '/api/resellers/clients',
      {
        'name': name,
        'email': email,
        if (productInterest != null && productInterest.trim().isNotEmpty)
          'product_interest': productInterest.trim(),
        'status': _clientStatusApi(status),
      },
      auth: true,
    );
    return ResellerClient(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? name,
      email: json['email']?.toString() ?? email,
      status: _mapClientStatus(json['status']?.toString()),
      productInterest: json['product_interest']?.toString() ?? productInterest,
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  Future<void> updateClientStatus({
    required String resellerEmail,
    required String clientId,
    required ResellerClientStatus status,
  }) async {
    await _api.putJson(
      '/api/resellers/clients/$clientId',
      {'status': _clientStatusApi(status)},
      auth: true,
    );
  }

  @override
  Future<List<ResellerSale>> getSales(String email) async {
    final sales = await _api.getList('/api/resellers/sales', auth: true);
    final commissions =
        await _api.getList('/api/resellers/commissions', auth: true);
    final commissionByOrder = <String, double>{};
    for (final raw in commissions) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final party = (m['party']?.toString() ?? 'seller').toLowerCase();
      if (party == 'digititan') continue;
      final orderId = m['order_id']?.toString() ?? '';
      final amount = _asDouble(m['amount']) ?? 0;
      if (orderId.isNotEmpty) {
        commissionByOrder[orderId] = (commissionByOrder[orderId] ?? 0) + amount;
      }
    }

    return sales.whereType<Map>().map((raw) {
      final m = Map<String, dynamic>.from(raw);
      final id = m['id']?.toString() ?? '';
      final total = _asDouble(m['total']) ?? 0;
      final fromSale = _asDouble(m['commission_amount']);
      return ResellerSale(
        id: id,
        clientName: m['customer_name']?.toString() ?? 'Customer',
        productName: 'Order #$id',
        amount: total,
        commission: fromSale ?? commissionByOrder[id] ?? 0,
        date: DateTime.tryParse(m['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<String> getMonthlyStatement(String email) async {
    final now = DateTime.now().toUtc();
    final month =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    try {
      final json = await _api.getJson(
        '/api/resellers/statement',
        auth: true,
        query: {'month': month},
      );
      final period = json['period'] is Map
          ? Map<String, dynamic>.from(json['period'] as Map)
          : <String, dynamic>{};
      final code = json['referral_code']?.toString() ?? '';
      final academy = json['academy']?.toString();
      final affiliated = json['affiliated'] == true;
      final isCentre = json['is_centre'] == true;
      final path = isCentre
          ? 'Centre (VNA-C) · 26%'
          : affiliated
              ? 'Affiliated (VNA-B) · 53 / 26 / 21'
              : 'Independent (VNA-B) · 53%';

      final buf = StringBuffer()
        ..writeln('DIGITITAN / VILLAGE NETACAD — MONTHLY STATEMENT')
        ..writeln('Period: $month (UTC)')
        ..writeln('Reseller: ${json['referral_code'] ?? code}')
        ..writeln('Path: $path')
        ..writeln(
            'Academy / centre note: ${academy == null || academy.isEmpty ? '—' : academy}')
        ..writeln('')
        ..writeln(
            'Orders (period): R${_fmt(period['orders_total'])}')
        ..writeln(
            'Your wallet credit (period): R${_fmt(period['seller_earned'])}')
        ..writeln(
            'Centre share credited (period): R${_fmt(period['centre_earned'])}')
        ..writeln(
            'Digititan share (period): R${_fmt(period['digititan_due'])}')
        ..writeln('')
        ..writeln(
            'Lifetime total earned: R${_fmt(json['total_earned'])}')
        ..writeln(
            'Wallet balance now: R${_fmt(json['wallet_balance'])}')
        ..writeln('')
        ..writeln(
            'Withdrawals: last calendar day of the month only · min R${AppConfig.minWithdrawalZar.toStringAsFixed(0)}')
        ..writeln('(Server-enforced on live API.)');

      final lines = json['lines'];
      if (lines is List && lines.isNotEmpty) {
        buf.writeln('');
        buf.writeln('Lines:');
        for (final raw in lines.take(40)) {
          if (raw is! Map) continue;
          final m = Map<String, dynamic>.from(raw);
          final party = m['party']?.toString() ?? 'seller';
          final oid = m['order_id']?.toString() ?? '?';
          final cust = m['customer_name']?.toString() ?? '';
          buf.writeln(
            '  #$oid · $party · R${_fmt(m['amount'])} · $cust',
          );
        }
      }
      return buf.toString();
    } catch (_) {
      final profile = await getProfile(email);
      return '''
DIGITITAN / VILLAGE NETACAD — EARNINGS STATEMENT
Reseller: ${profile.name} <$email>
Code: ${profile.code}
Status: ${profile.status}

Total earned: R${profile.totalEarned.toStringAsFixed(2)}
Wallet balance: R${profile.balance.toStringAsFixed(2)}
Commission rate: ${profile.commissionRate.toStringAsFixed(0)}%
Centre share (lifetime): R${profile.centreShareTotal.toStringAsFixed(2)}
Digititan share (lifetime): R${profile.amountDueToDigititan.toStringAsFixed(2)}

Withdrawals: last calendar day of the month only · min R${AppConfig.minWithdrawalZar.toStringAsFixed(0)}
(Server-enforced on live API.)
''';
    }
  }

  @override
  Future<void> requestWithdrawal({
    required String email,
    required double amount,
  }) async {
    await _api.postJson(
      '/api/resellers/withdraw',
      {'amount': amount, 'bank_details': <String, dynamic>{}},
      auth: true,
    );
  }

  @override
  Future<IssuedResellerCode> verifyCode(String code) async {
    final normalized = Uri.encodeComponent(code.trim().toUpperCase());
    final json = await _api.getJson(
      '/api/resellers/verify/$normalized',
      auth: false,
    );
    final status = (json['status']?.toString() ?? '').toLowerCase();
    final approved = json['approved'] == true || status == 'approved';
    final active = json['active'] == true || approved;
    final rawCode = json['code']?.toString() ?? code.trim().toUpperCase();
    return IssuedResellerCode(
      code: rawCode,
      type: _codeTypeFrom(rawCode),
      resellerEmail: '',
      resellerName: json['name']?.toString() ?? 'Reseller',
      academyName: json['academy']?.toString(),
      issuedAt: DateTime.now(),
      active: active,
    );
  }

  ResellerProfile _mapProfile(
    Map<String, dynamic> json, {
    required String fallbackEmail,
  }) {
    final code = json['referral_code']?.toString() ?? 'PENDING';
    final rate = _asDouble(json['commission_rate']) ??
        RevenueSplit.beneficiaryPercent;
    final status = _mapStatus(json['status']?.toString());
    return ResellerProfile(
      email: json['email']?.toString() ?? fallbackEmail.trim().toLowerCase(),
      name: json['name']?.toString() ?? 'Reseller',
      code: code,
      codeType: _codeTypeFrom(code),
      status: status,
      totalEarned: _asDouble(json['total_earned']) ?? 0,
      balance: _asDouble(json['wallet_balance']) ?? 0,
      amountDueToDigititan: _asDouble(json['amount_due_to_digititan']) ?? 0,
      centreShareTotal: _asDouble(json['centre_share_total']) ?? 0,
      commissionRate: rate,
      academyName: json['academy']?.toString(),
    );
  }

  static String _fmt(dynamic value) {
    final n = _asDouble(value) ?? 0;
    return n.toStringAsFixed(2);
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  String _mapStatus(String? raw) {
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

  ResellerClientStatus _mapClientStatus(String? raw) {
    switch ((raw ?? '').toLowerCase().replaceAll('-', '_')) {
      case 'confirmed':
        return ResellerClientStatus.confirmed;
      case 'bought':
        return ResellerClientStatus.bought;
      case 'did_not_buy':
      case 'didnotbuy':
        return ResellerClientStatus.didNotBuy;
      default:
        return ResellerClientStatus.pending;
    }
  }

  String _clientStatusApi(ResellerClientStatus status) {
    switch (status) {
      case ResellerClientStatus.pending:
        return 'pending';
      case ResellerClientStatus.confirmed:
        return 'confirmed';
      case ResellerClientStatus.bought:
        return 'bought';
      case ResellerClientStatus.didNotBuy:
        return 'did_not_buy';
    }
  }

  ResellerCodeType _codeTypeFrom(String code) {
    final upper = code.trim().toUpperCase();
    // Live provisional codes look like VNA-2D23BA54 or VNA-C1A2B3D4 (hex after
    // one hyphen). Only explicit issued forms VNA-C-* / VNA-B-* are centre /
    // beneficiary. Do NOT treat "VNA-C" + hex as a centre code.
    if (upper.startsWith('VNA-C-')) return ResellerCodeType.centre;
    if (upper.startsWith('VNA-B-')) return ResellerCodeType.beneficiary;
    return ResellerCodeType.beneficiary;
  }
}

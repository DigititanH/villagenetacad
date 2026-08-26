import '../../domain/entities/reseller.dart';
import '../../domain/entities/revenue_split.dart';
import '../../domain/repositories/reseller_repository.dart';
import '../../shared/config/app_config.dart';
import 'api_client.dart';

/// Live reseller APIs on villagenetacad.co.za.
///
/// Clients CRM is not on the website yet — [getClients] returns empty.
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
    // No live clients/leads API yet (Phase 8 later).
    return const [];
  }

  @override
  Future<ResellerClient> addClient({
    required String resellerEmail,
    required String name,
    required String email,
    String? productInterest,
    ResellerClientStatus status = ResellerClientStatus.pending,
  }) async {
    throw Exception('Client CRM is not available on the live API yet');
  }

  @override
  Future<void> updateClientStatus({
    required String resellerEmail,
    required String clientId,
    required ResellerClientStatus status,
  }) async {
    throw Exception('Client CRM is not available on the live API yet');
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
      final orderId = m['order_id']?.toString() ?? '';
      final amount = _asDouble(m['amount']) ?? 0;
      if (orderId.isNotEmpty) commissionByOrder[orderId] = amount;
    }

    return sales.whereType<Map>().map((raw) {
      final m = Map<String, dynamic>.from(raw);
      final id = m['id']?.toString() ?? '';
      final total = _asDouble(m['total']) ?? 0;
      return ResellerSale(
        id: id,
        clientName: m['customer_name']?.toString() ?? 'Customer',
        productName: 'Order #$id',
        amount: total,
        commission: commissionByOrder[id] ?? 0,
        date: DateTime.tryParse(m['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<String> getMonthlyStatement(String email) async {
    final profile = await getProfile(email);
    return '''
DIGITITAN / VILLAGE NETACAD — EARNINGS STATEMENT
Reseller: ${profile.name} <$email>
Code: ${profile.code}
Status: ${profile.status}

Total earned: R${profile.totalEarned.toStringAsFixed(2)}
Wallet balance: R${profile.balance.toStringAsFixed(2)}
Commission rate: ${profile.commissionRate.toStringAsFixed(0)}%

Withdrawals: last calendar day of the month only · min R${AppConfig.minWithdrawalZar.toStringAsFixed(0)}
(Server-enforced on live API.)
''';
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
    if (!active && !approved) {
      // Still return details so UI can show "not approved"
    }
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
      amountDueToDigititan: 0,
      centreShareTotal: 0,
      commissionRate: rate,
      academyName: json['academy']?.toString(),
    );
  }

  /// PHP/MySQL JSON often sends decimals as strings ("0.00").
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

  ResellerCodeType _codeTypeFrom(String code) {
    final upper = code.toUpperCase();
    if (upper.startsWith('VNA-C')) return ResellerCodeType.centre;
    return ResellerCodeType.beneficiary;
  }
}

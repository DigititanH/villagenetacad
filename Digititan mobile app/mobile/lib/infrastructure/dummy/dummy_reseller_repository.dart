import '../../domain/entities/reseller.dart';
import '../../domain/entities/revenue_split.dart';
import '../../domain/entities/withdrawal_request.dart';
import '../../domain/repositories/reseller_repository.dart';
import '../../shared/config/app_config.dart';
import 'demo_hub.dart';

class DummyResellerRepository implements ResellerRepository {
  final _hub = DemoHub.instance;

  @override
  Future<ResellerProfile> getProfile(String email) async {
    final key = email.trim().toLowerCase();
    final profile = _hub.resellerProfiles[key];
    if (profile != null) return profile;
    return ResellerProfile(
      email: key,
      name: key,
      code: 'PENDING',
      codeType: ResellerCodeType.beneficiary,
      status: 'pending',
      totalEarned: 0,
      balance: 0,
      amountDueToDigititan: 0,
      centreShareTotal: 0,
      commissionRate: RevenueSplit.beneficiaryPercent,
    );
  }

  @override
  Future<void> applyToBecomeReseller({
    required String name,
    required String email,
    String? academyName,
  }) async {
    _hub.applyReseller(
      name: name,
      email: email,
      academyName: academyName,
    );
  }

  @override
  Future<List<ResellerClient>> getClients(String email) async {
    final key = email.trim().toLowerCase();
    return List.unmodifiable(_hub.resellerClients[key] ?? const []);
  }

  @override
  Future<ResellerClient> addClient({
    required String resellerEmail,
    required String name,
    required String email,
    String? productInterest,
    ResellerClientStatus status = ResellerClientStatus.pending,
  }) async {
    return _hub.addClient(
      resellerEmail: resellerEmail,
      name: name,
      email: email,
      productInterest: productInterest,
      status: status,
    );
  }

  @override
  Future<void> updateClientStatus({
    required String resellerEmail,
    required String clientId,
    required ResellerClientStatus status,
  }) async {
    _hub.updateClientStatus(
      resellerEmail: resellerEmail,
      clientId: clientId,
      status: status,
    );
  }

  @override
  Future<List<ResellerSale>> getSales(String email) async {
    final key = email.trim().toLowerCase();
    return List.unmodifiable(_hub.resellerSales[key] ?? const []);
  }

  @override
  Future<String> getMonthlyStatement(String email) async {
    final profile = await getProfile(email);
    if (!profile.isApproved) {
      return '''
DIGITITAN / VILLAGE NETACAD — RESELLER APPLICATION
Reseller: ${profile.name} <$email>
Status: PENDING APPROVAL

Ops Admin must approve this application and issue a Centre (VNA-C-*)
or Beneficiary (VNA-B-*) code before you can sell or manage clients.
''';
    }
    final sellerLabel = profile.codeType == ResellerCodeType.centre
        ? 'Your Centre earnings (26%)'
        : 'Your earnings (53%)';
    return '''
DIGITITAN / VILLAGE NETACAD — YOUR EARNINGS STATEMENT
Reseller: ${profile.name} <$email>
Code: ${profile.code} (${profile.codeType.label})
Period: current demo month

$sellerLabel
Total earned (your share only): R${profile.totalEarned.toStringAsFixed(2)}
Money due to you now: R${profile.balance.toStringAsFixed(2)}

You only see money due to you — not the full sale price or other shares.

Withdrawals: last calendar day of the month only
(next unlock: ${DateTime(DateTime.now().year, DateTime.now().month + 1, 0).toIso8601String().substring(0, 10)}).
Super Admin still approves the payout.
''';
  }

  @override
  Future<void> requestWithdrawal({
    required String email,
    required double amount,
  }) async {
    final key = email.trim().toLowerCase();
    final profile = _hub.resellerProfiles[key];
    if (profile == null || !profile.isApproved) {
      throw Exception('Reseller must be approved before requesting withdrawal');
    }
    // Calendar gate is enforced in UI; keep amount validation here.
    if (amount < AppConfig.minWithdrawalZar) {
      throw Exception(
        'Minimum withdrawal is R${AppConfig.minWithdrawalZar.toStringAsFixed(0)}',
      );
    }
    if (amount <= 0 || amount > profile.balance) {
      throw Exception('Invalid withdrawal amount');
    }
    _hub.resellerProfiles[key] =
        profile.copyWith(balance: profile.balance - amount);
    _hub.withdrawals.insert(
      0,
      WithdrawalRequest(
        id: 'w-${DateTime.now().millisecondsSinceEpoch}',
        resellerEmail: key,
        resellerName: profile.name,
        amount: amount,
        createdAt: DateTime.now(),
      ),
    );
    _hub.log('Withdrawal requested $key R$amount (awaiting Super Admin)');
  }

  @override
  Future<IssuedResellerCode> verifyCode(String code) async {
    final normalized = code.trim().toUpperCase();
    final issued = _hub.findCode(normalized);
    if (issued == null || !issued.active) {
      throw Exception('Code not found or inactive');
    }
    return issued;
  }
}

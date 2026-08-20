import '../../domain/entities/reseller.dart';
import '../../domain/entities/revenue_split.dart';
import '../../domain/repositories/reseller_repository.dart';
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
    final sales = await getSales(email);
    final salesTotal = sales.fold<double>(0, (s, x) => s + x.amount);
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
        ? 'Centre share (${RevenueSplit.centrePercent.toStringAsFixed(0)}%)'
        : 'Reseller/Beneficiary share (${RevenueSplit.beneficiaryPercent.toStringAsFixed(0)}%)';
    return '''
DIGITITAN / VILLAGE NETACAD — RESELLER STATEMENT (PROTOTYPE)
Reseller: ${profile.name} <$email>
Code: ${profile.code} (${profile.codeType.label})
Status: ${profile.status}
Period: current demo month

Sales total: R${salesTotal.toStringAsFixed(2)}

SPLIT (locked): Reseller/Beneficiary ${RevenueSplit.beneficiaryPercent.toStringAsFixed(0)}% · Centre ${RevenueSplit.centrePercent.toStringAsFixed(0)}% · Digititan/Village NetAcad ${RevenueSplit.digititanPercent.toStringAsFixed(0)}%

$sellerLabel earned: R${profile.totalEarned.toStringAsFixed(2)}
Available balance (Digititan pays you): R${profile.balance.toStringAsFixed(2)}
Centre allocation tracked: R${profile.centreShareTotal.toStringAsFixed(2)}
Amount due to Digititan / Village NetAcad: R${profile.amountDueToDigititan.toStringAsFixed(2)}

Money flow: Digititan pays resellers at month-end (with approval).
Bank auto-debit: later (not V1).
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
}

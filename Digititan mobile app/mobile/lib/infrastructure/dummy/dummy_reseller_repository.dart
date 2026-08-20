import '../../domain/entities/reseller.dart';
import '../../domain/repositories/reseller_repository.dart';
import 'demo_hub.dart';

class DummyResellerRepository implements ResellerRepository {
  final _hub = DemoHub.instance;

  @override
  Future<ResellerProfile> getProfile(String email) async {
    final key = email.trim().toLowerCase();
    final profile = _hub.resellerProfiles[key];
    if (profile != null) return profile;
    // Unapproved / unknown reseller shell
    return ResellerProfile(
      email: key,
      name: key,
      code: 'PENDING',
      codeType: ResellerCodeType.beneficiary,
      status: 'pending',
      totalEarned: 0,
      balance: 0,
      amountDueToDigititan: 0,
      commissionRate: 12,
    );
  }

  @override
  Future<List<ResellerClient>> getClients(String email) async {
    final key = email.trim().toLowerCase();
    return List.unmodifiable(_hub.resellerClients[key] ?? const []);
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
    final commission = sales.fold<double>(0, (s, x) => s + x.commission);
    return '''
DIGITITAN / VILLAGE NETACAD — RESELLER STATEMENT (PROTOTYPE)
Reseller: ${profile.name} <$email>
Code: ${profile.code} (${profile.codeType.label})
Status: ${profile.status}
Period: current demo month

Sales total: R${salesTotal.toStringAsFixed(2)}
Commission earned: R${commission.toStringAsFixed(2)}
Available balance: R${profile.balance.toStringAsFixed(2)}

Money flow: Digititan pays all resellers at month-end (with approval).
Centre codes (VNA-C-*) vs Beneficiary codes (VNA-B-*) are tracked separately.
''';
  }

  @override
  Future<void> requestWithdrawal({
    required String email,
    required double amount,
  }) async {
    final key = email.trim().toLowerCase();
    final profile = _hub.resellerProfiles[key];
    if (profile == null) throw Exception('Reseller profile not found');
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

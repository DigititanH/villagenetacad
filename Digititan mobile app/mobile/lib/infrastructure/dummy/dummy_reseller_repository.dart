import '../../domain/entities/reseller.dart';
import '../../domain/repositories/reseller_repository.dart';

class DummyResellerRepository implements ResellerRepository {
  final List<ResellerClient> _clients = [
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
    ResellerClient(
      id: 'c4',
      name: 'Thabo Mokoena',
      email: 'thabo2@example.com',
      status: ResellerClientStatus.didNotBuy,
      productInterest: 'Wireless Mouse',
      updatedAt: DateTime(2026, 7, 28),
    ),
  ];

  final List<ResellerSale> _sales = [
    ResellerSale(
      id: 's1',
      clientName: 'Nomsa Dlamini',
      productName: 'Home Lab Network Kit',
      amount: 899,
      commission: 107.88,
      date: DateTime(2026, 8, 1),
    ),
    ResellerSale(
      id: 's2',
      clientName: 'Aisha Patel',
      productName: 'Digititan Laptop Bag',
      amount: 349,
      commission: 41.88,
      date: DateTime(2026, 7, 22),
    ),
  ];

  double _balance = 960;

  @override
  Future<ResellerProfile> getProfile(String email) async {
    return ResellerProfile(
      code: 'VNA-LERATO',
      status: 'approved',
      totalEarned: 4280,
      balance: _balance,
      amountDueToDigititan: 312.5,
      commissionRate: 12,
      academyName: 'Lesedi Labatu Academy',
    );
  }

  @override
  Future<List<ResellerClient>> getClients(String email) async =>
      List.unmodifiable(_clients);

  @override
  Future<List<ResellerSale>> getSales(String email) async =>
      List.unmodifiable(_sales);

  @override
  Future<String> getMonthlyStatement(String email) async {
    return '''
DIGITITAN / VILLAGE NETACAD — RESELLER STATEMENT (PROTOTYPE)
Reseller: $email
Code: VNA-LERATO
Period: July 2026

Sales total: R1,248.00
Commission earned: R149.76
Amount Digititan will pay reseller: R${_balance.toStringAsFixed(2)}

Money flow (locked decision): Digititan pays all resellers.
Withdrawals: end of month with approval.
Bank auto-debit from reseller accounts: later (not V1).
Exact split % will be shown to resellers once leadership publishes final rates.
''';
  }

  @override
  Future<void> requestWithdrawal({
    required String email,
    required double amount,
  }) async {
    if (amount <= 0 || amount > _balance) {
      throw Exception('Invalid withdrawal amount');
    }
    _balance -= amount;
    // ignore: avoid_print
    print('WITHDRAWAL REQUESTED: $email amount=R$amount remaining=$_balance');
  }
}

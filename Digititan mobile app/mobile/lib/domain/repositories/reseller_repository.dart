import '../entities/reseller.dart';

abstract class ResellerRepository {
  Future<ResellerProfile> getProfile(String email);

  /// Register / apply as reseller — waits for Ops Admin approval + code.
  Future<void> applyToBecomeReseller({
    required String name,
    required String email,
    String? academyName,
  });

  Future<List<ResellerClient>> getClients(String email);
  Future<ResellerClient> addClient({
    required String resellerEmail,
    required String name,
    required String email,
    String? productInterest,
    ResellerClientStatus status,
  });
  Future<void> updateClientStatus({
    required String resellerEmail,
    required String clientId,
    required ResellerClientStatus status,
  });

  Future<List<ResellerSale>> getSales(String email);
  Future<String> getMonthlyStatement(String email);
  Future<void> requestWithdrawal({
    required String email,
    required double amount,
  });

  /// Public legitimacy check (live API or DemoHub).
  Future<IssuedResellerCode> verifyCode(String code);
}

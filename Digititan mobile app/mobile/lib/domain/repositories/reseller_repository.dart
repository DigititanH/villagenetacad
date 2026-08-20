import '../entities/reseller.dart';

abstract class ResellerRepository {
  Future<ResellerProfile> getProfile(String email);
  Future<List<ResellerClient>> getClients(String email);
  Future<List<ResellerSale>> getSales(String email);
  Future<String> getMonthlyStatement(String email);
  Future<void> requestWithdrawal({
    required String email,
    required double amount,
  });
}

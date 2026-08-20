import '../../domain/entities/shop_order.dart';
import '../../domain/repositories/store_repository.dart';
import '../../shared/result/result.dart';

class PlaceOrder {
  final StoreRepository _repo;
  PlaceOrder(this._repo);

  Future<Result<ShopOrder>> call({
    required String buyerEmail,
    required String buyerName,
    required String otp,
    String? referralCode,
  }) async {
    if (!_repo.verifyPaymentOtp(buyerEmail, otp)) {
      return const Failure('Invalid payment OTP');
    }
    try {
      final order = await _repo.placeOrder(
        buyerEmail: buyerEmail,
        buyerName: buyerName,
        referralCode: referralCode,
      );
      return Success(order);
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

import '../../domain/entities/shop_order.dart';
import '../../domain/repositories/store_repository.dart';
import '../../shared/result/result.dart';
import '../../shared/utils/friendly_api_error.dart';

class GetMyOrders {
  final StoreRepository _repo;
  GetMyOrders(this._repo);

  Future<Result<List<ShopOrder>>> call(String email) async {
    try {
      return Success(await _repo.getOrdersFor(email));
    } catch (e) {
      return Failure(friendlyApiError(e));
    }
  }
}

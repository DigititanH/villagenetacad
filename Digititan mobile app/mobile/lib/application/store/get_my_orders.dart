import '../../domain/entities/shop_order.dart';
import '../../domain/repositories/store_repository.dart';
import '../../shared/result/result.dart';

class GetMyOrders {
  final StoreRepository _repo;
  GetMyOrders(this._repo);

  Future<Result<List<ShopOrder>>> call(String email) async {
    try {
      return Success(await _repo.getOrdersFor(email));
    } catch (e) {
      return Failure(e.toString());
    }
  }
}

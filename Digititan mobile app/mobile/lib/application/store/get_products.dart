import '../../domain/entities/product.dart';
import '../../domain/repositories/store_repository.dart';
import '../../shared/result/result.dart';
import '../../shared/utils/friendly_api_error.dart';

class GetProducts {
  final StoreRepository _repo;
  GetProducts(this._repo);

  Future<Result<List<Product>>> call() async {
    try {
      return Success(await _repo.getProducts());
    } catch (e) {
      return Failure(friendlyApiError(e));
    }
  }
}

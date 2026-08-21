import '../../domain/entities/academy.dart';
import '../../domain/repositories/academy_repository.dart';
import '../../shared/result/result.dart';

class GetAcademies {
  final AcademyRepository _repo;
  GetAcademies(this._repo);

  Future<Result<List<Academy>>> call({String? province}) async {
    try {
      return Success(await _repo.getAcademies(province: province));
    } catch (e) {
      return Failure(e.toString());
    }
  }
}

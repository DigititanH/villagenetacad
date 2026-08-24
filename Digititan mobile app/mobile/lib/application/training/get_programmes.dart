import '../../domain/entities/programme_highlight.dart';
import '../../domain/repositories/training_repository.dart';
import '../../shared/result/result.dart';

class GetProgrammes {
  final TrainingRepository _repo;
  GetProgrammes(this._repo);

  Future<Result<List<ProgrammeHighlight>>> call() async {
    try {
      return Success(await _repo.getProgrammes());
    } catch (e) {
      return Failure(e.toString());
    }
  }
}

import '../../domain/entities/training_offer.dart';
import '../../domain/repositories/training_repository.dart';
import '../../shared/result/result.dart';

class GetTrainingOffers {
  final TrainingRepository _repo;
  GetTrainingOffers(this._repo);

  Future<Result<List<TrainingOffer>>> call() async {
    try {
      return Success(await _repo.getOffers());
    } catch (e) {
      return Failure(e.toString());
    }
  }
}

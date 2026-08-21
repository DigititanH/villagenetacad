import '../../domain/repositories/training_repository.dart';
import '../../shared/result/result.dart';

class RegisterTrainingInterest {
  final TrainingRepository _repo;
  RegisterTrainingInterest(this._repo);

  Future<Result<void>> call({
    required String trainingId,
    required String fullName,
    required String email,
    required String phone,
  }) async {
    if (fullName.trim().isEmpty || email.trim().isEmpty) {
      return const Failure('Name and email are required');
    }
    try {
      await _repo.registerInterest(
        trainingId: trainingId,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}

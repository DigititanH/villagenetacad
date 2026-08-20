import '../../domain/repositories/academy_repository.dart';
import '../../shared/result/result.dart';

class RegisterAcademyInterest {
  final AcademyRepository _repo;
  RegisterAcademyInterest(this._repo);

  Future<Result<void>> call({
    required String academyId,
    required String fullName,
    required String email,
    required String phone,
    required String notes,
  }) async {
    if (fullName.trim().isEmpty || email.trim().isEmpty) {
      return const Failure('Name and email are required');
    }
    try {
      await _repo.registerInterest(
        academyId: academyId,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        notes: notes.trim(),
      );
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}

import '../../domain/repositories/academy_repository.dart';
import '../../shared/result/result.dart';

class RegisterAcademyOrganisation {
  final AcademyRepository _repo;
  RegisterAcademyOrganisation(this._repo);

  Future<Result<void>> call({
    required String organisationName,
    required String contactName,
    required String email,
    required String phone,
    required String province,
  }) async {
    if (organisationName.trim().isEmpty ||
        contactName.trim().isEmpty ||
        email.trim().isEmpty) {
      return const Failure('Organisation, contact name and email are required');
    }
    try {
      await _repo.registerOrganisation(
        organisationName: organisationName.trim(),
        contactName: contactName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        province: province,
      );
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}

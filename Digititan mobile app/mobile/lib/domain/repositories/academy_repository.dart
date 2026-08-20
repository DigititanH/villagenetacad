import '../entities/academy.dart';

abstract class AcademyRepository {
  Future<List<String>> getProvinces();
  Future<List<Academy>> getAcademies({String? province});
  Future<Academy?> getById(String id);
  Future<void> registerInterest({
    required String academyId,
    required String fullName,
    required String email,
    required String phone,
    required String notes,
  });
  Future<void> registerOrganisation({
    required String organisationName,
    required String contactName,
    required String email,
    required String phone,
    required String province,
  });
}

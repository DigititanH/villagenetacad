import '../../domain/entities/programme_highlight.dart';
import '../../domain/entities/training_offer.dart';
import '../../domain/repositories/training_repository.dart';
import '../courses/website_courses_catalogue.dart';
import 'demo_hub.dart';

/// Training catalogue = hardcoded website courses (Phase 9 slice A).
/// Free → Cisco; paid CCNA → website PayFast enrol page.
class DummyTrainingRepository implements TrainingRepository {
  List<TrainingOffer> get _offers => WebsiteCoursesCatalogue.offers;

  final List<ProgrammeHighlight> _programmes = const [
    ProgrammeHighlight(
      id: 'pg-ccna-paid',
      title: 'CCNA pathway (paid)',
      subtitle: 'R550 × 6 months via website PayFast — CCNA 1, 2 and 3.',
      isRecruiting: true,
    ),
    ProgrammeHighlight(
      id: 'pg-free-skills',
      title: 'Free Skills for All',
      subtitle: 'Self-paced Cisco NetAcad courses under Village NetAcad.',
      isRecruiting: true,
    ),
  ];

  final List<Map<String, String>> interests = [];

  @override
  Future<List<TrainingOffer>> getOffers() async => List.unmodifiable(_offers);

  @override
  Future<TrainingOffer?> getOfferById(String id) async {
    try {
      return _offers.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProgrammeHighlight>> getProgrammes() async =>
      List.unmodifiable(_programmes);

  @override
  Future<void> registerInterest({
    required String trainingId,
    required String fullName,
    required String email,
    required String phone,
    required String gender,
  }) async {
    // Kept for demo/admin lead queue; primary enrol is Cisco / website pay.
    interests.add({
      'trainingId': trainingId,
      'fullName': fullName,
      'email': email,
      'gender': gender,
      'phone': phone,
      'at': DateTime.now().toIso8601String(),
    });
    final offer = await getOfferById(trainingId);
    DemoHub.instance.trainingInterests.insert(
      0,
      InterestLead(
        id: 'ti-${DateTime.now().millisecondsSinceEpoch}',
        subjectId: trainingId,
        subjectTitle: offer?.title ?? trainingId,
        fullName: fullName,
        email: email,
        phone: phone,
        gender: gender,
        notes: '',
        createdAt: DateTime.now(),
      ),
    );
    DemoHub.instance.log(
      'Training interest: ${offer?.title ?? trainingId} by $fullName ($gender)',
    );
  }
}

import '../../domain/entities/programme_highlight.dart';
import '../../domain/entities/training_offer.dart';
import '../../domain/repositories/training_repository.dart';
import 'demo_hub.dart';

/// In-memory training catalogue for prototype demos.
class DummyTrainingRepository implements TrainingRepository {
  final List<TrainingOffer> _offers = const [
    TrainingOffer(
      id: 'tr-net-basics',
      title: 'Networking Basics',
      category: 'Networking',
      level: 'Beginner',
      hours: 22,
      summary: 'Start learning how networks operate and build foundational skills.',
      recruitmentOpen: true,
    ),
    TrainingOffer(
      id: 'tr-cyber-intro',
      title: 'Introduction to Cybersecurity',
      category: 'Cybersecurity',
      level: 'Beginner',
      hours: 6,
      summary: 'Explore cybersecurity and why it is a future-proof career.',
      recruitmentOpen: true,
    ),
    TrainingOffer(
      id: 'tr-python',
      title: 'Python Essentials',
      category: 'Programming & Linux',
      level: 'Beginner',
      hours: 70,
      summary: 'Build Python skills from zero toward certification readiness.',
    ),
    TrainingOffer(
      id: 'tr-ccna-1',
      title: 'CCNA: Introduction to Networks',
      category: 'Networking',
      level: 'Intermediate',
      hours: 70,
      summary: 'First course in the CCNA series for associate-level jobs.',
      recruitmentOpen: true,
    ),
    TrainingOffer(
      id: 'tr-it-support',
      title: 'IT Customer Support Basics',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 4,
      summary: 'Help-desk skills for entry-level IT support roles.',
    ),
  ];

  final List<ProgrammeHighlight> _programmes = const [
    ProgrammeHighlight(
      id: 'pg-youth-2026',
      title: 'Youth Tech Intake 2026',
      subtitle: 'Open recruitment for young people entering IT pathways.',
      isRecruiting: true,
    ),
    ProgrammeHighlight(
      id: 'pg-cyber-path',
      title: 'Junior Cybersecurity Path',
      subtitle: 'Structured pathway into cyber defence roles.',
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
      'Training interest (LMS): ${offer?.title ?? trainingId} by $fullName '
      '($gender) <$email>',
    );
  }
}

import '../entities/programme_highlight.dart';
import '../entities/training_offer.dart';

/// Abstraction for training/home content.
abstract class TrainingRepository {
  Future<List<TrainingOffer>> getOffers();
  Future<TrainingOffer?> getOfferById(String id);
  Future<List<ProgrammeHighlight>> getProgrammes();
  Future<void> registerInterest({
    required String trainingId,
    required String fullName,
    required String email,
    required String phone,
  });
}

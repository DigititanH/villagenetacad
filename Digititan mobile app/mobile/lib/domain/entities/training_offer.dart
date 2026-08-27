/// Training offering shown in Training section / Home hub.
///
/// Phase 9 slice A: catalogue is hardcoded like the website (not MySQL).
class TrainingOffer {
  final String id;
  final String title;
  final String category;
  final String level;
  final int hours;
  final String summary;
  final bool recruitmentOpen;

  /// Display price from website (`Free` or `R550/mo`).
  final String priceLabel;

  /// Cisco NetAcad enrol URL for free courses. Null for paid website pathways.
  final String? ciscoEnrollUrl;

  /// Paid pathway (e.g. CCNA) — open Village NetAcad website enrol/PayFast.
  final bool isPaidOnWebsite;

  const TrainingOffer({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.hours,
    required this.summary,
    this.recruitmentOpen = true,
    this.priceLabel = 'Free',
    this.ciscoEnrollUrl,
    this.isPaidOnWebsite = false,
  });

  bool get isFreeCisco =>
      !isPaidOnWebsite &&
      ciscoEnrollUrl != null &&
      ciscoEnrollUrl!.trim().isNotEmpty;
}

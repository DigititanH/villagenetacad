/// Training offering shown in Training section / Home hub.
class TrainingOffer {
  final String id;
  final String title;
  final String category;
  final String level;
  final int hours;
  final String summary;
  final bool recruitmentOpen;

  const TrainingOffer({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.hours,
    required this.summary,
    this.recruitmentOpen = false,
  });
}

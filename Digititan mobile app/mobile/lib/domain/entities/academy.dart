/// Upcoming event hosted by an academy (prototype / dummy data).
class AcademyEvent {
  final String title;
  final String dateLabel;
  final String description;

  const AcademyEvent({
    required this.title,
    required this.dateLabel,
    required this.description,
  });
}

class Academy {
  final String id;
  final String name;
  final String province;
  final String city;
  final String address;
  final String summary;
  final bool isActive;
  final bool isRecruiting;
  final String? recruitmentDates;
  final List<String> programmes;
  final List<AcademyEvent> events;
  /// WGS84 — used to place the pin on the SA map prototype.
  final double latitude;
  final double longitude;

  const Academy({
    required this.id,
    required this.name,
    required this.province,
    required this.city,
    required this.address,
    required this.summary,
    required this.isActive,
    required this.latitude,
    required this.longitude,
    this.isRecruiting = false,
    this.recruitmentDates,
    this.programmes = const [],
    this.events = const [],
  });

  /// Back-compat alias used by older screens.
  List<String> get coursesOffered => programmes;
}

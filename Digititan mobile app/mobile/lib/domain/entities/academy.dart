class Academy {
  final String id;
  final String name;
  final String province;
  final String city;
  final String summary;
  final bool isActive;
  final bool isRecruiting;
  final String? recruitmentDates;
  final List<String> coursesOffered;

  const Academy({
    required this.id,
    required this.name,
    required this.province,
    required this.city,
    required this.summary,
    required this.isActive,
    this.isRecruiting = false,
    this.recruitmentDates,
    this.coursesOffered = const [],
  });
}

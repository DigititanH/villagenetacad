class ProgrammeHighlight {
  final String id;
  final String title;
  final String subtitle;
  final bool isRecruiting;

  const ProgrammeHighlight({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isRecruiting = false,
  });
}

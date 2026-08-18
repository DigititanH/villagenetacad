import '../../domain/entities/academy.dart';
import '../../domain/repositories/academy_repository.dart';

class DummyAcademyRepository implements AcademyRepository {
  static const provinces = [
    'Gauteng',
    'Western Cape',
    'KwaZulu-Natal',
    'Eastern Cape',
    'Limpopo',
    'Mpumalanga',
    'Free State',
    'North West',
    'Northern Cape',
  ];

  final List<Academy> _academies = const [
    Academy(
      id: 'ac-lesedi',
      name: 'Lesedi Labatu Academy',
      province: 'Gauteng',
      city: 'Johannesburg',
      address: '12 Main Rd, Johannesburg, Gauteng',
      summary: 'Community tech academy focused on IT support and networking pathways.',
      isActive: true,
      isRecruiting: true,
      recruitmentDates: '1 Sep 2026 – 30 Sep 2026',
      latitude: -26.2041,
      longitude: 28.0473,
      programmes: ['Networking Basics', 'IT Customer Support Basics', 'Cyber Intro'],
      events: [
        AcademyEvent(
          title: 'Open Day — Networking lab tour',
          dateLabel: '5 Sep 2026',
          description: 'Meet trainers and see the lab setup.',
        ),
        AcademyEvent(
          title: 'Beneficiary registration drive',
          dateLabel: '12 Sep 2026',
          description: 'Walk-in registration with ID and proof of address.',
        ),
      ],
    ),
    Academy(
      id: 'ac-soweto',
      name: 'Soweto Digital Hub',
      province: 'Gauteng',
      city: 'Soweto',
      address: 'Vilakazi St area, Soweto, Gauteng',
      summary: 'Youth digital skills hub with self-paced and contact training options.',
      isActive: true,
      isRecruiting: true,
      recruitmentDates: '15 Aug 2026 – 15 Oct 2026',
      latitude: -26.2678,
      longitude: 27.8585,
      programmes: ['Python Essentials', 'Digital Literacy'],
      events: [
        AcademyEvent(
          title: 'Python intro workshop',
          dateLabel: '20 Sep 2026',
          description: 'Half-day intro for first-time coders.',
        ),
      ],
    ),
    Academy(
      id: 'ac-cpt',
      name: 'Cape Flats NetAcad Centre',
      province: 'Western Cape',
      city: 'Cape Town',
      address: 'Athlone, Cape Town, Western Cape',
      summary: 'Cisco-aligned networking centre supporting local beneficiaries.',
      isActive: true,
      isRecruiting: false,
      latitude: -33.9608,
      longitude: 18.6410,
      programmes: ['CCNA Intro', 'Networking Essentials'],
      events: [
        AcademyEvent(
          title: 'Parent information evening',
          dateLabel: '28 Sep 2026',
          description: 'How NetAcad pathways work for families.',
        ),
      ],
    ),
    Academy(
      id: 'ac-dbn',
      name: 'eThekwini Skills Academy',
      province: 'KwaZulu-Natal',
      city: 'Durban',
      address: 'Durban CBD, KwaZulu-Natal',
      summary: 'Coastal academy offering cyber and support pathways.',
      isActive: true,
      isRecruiting: true,
      recruitmentDates: 'Rolling intake',
      latitude: -29.8587,
      longitude: 31.0218,
      programmes: ['Introduction to Cybersecurity', 'Endpoint Security'],
      events: [
        AcademyEvent(
          title: 'Cyber awareness day',
          dateLabel: '10 Oct 2026',
          description: 'Talks + demos for schools and youth groups.',
        ),
      ],
    ),
    Academy(
      id: 'ac-pe',
      name: 'Gqeberha Tech Bridge',
      province: 'Eastern Cape',
      city: 'Gqeberha',
      address: 'Gqeberha, Eastern Cape',
      summary: 'Bridge programme for first-time IT learners.',
      isActive: false,
      isRecruiting: false,
      latitude: -33.9608,
      longitude: 25.6022,
      programmes: ['Computer Hardware Basics'],
      events: const [],
    ),
    Academy(
      id: 'ac-polokwane',
      name: 'Limpopo Future Coders',
      province: 'Limpopo',
      city: 'Polokwane',
      address: 'Polokwane, Limpopo',
      summary: 'Programming and digital literacy for rural youth outreach.',
      isActive: true,
      isRecruiting: true,
      recruitmentDates: 'Oct 2026',
      latitude: -23.9045,
      longitude: 29.4689,
      programmes: ['Python Essentials', 'Digital Awareness'],
      events: [
        AcademyEvent(
          title: 'Rural outreach signup',
          dateLabel: '3 Oct 2026',
          description: 'Registration for Oct intake.',
        ),
      ],
    ),
    Academy(
      id: 'ac-mbombela',
      name: 'Mpumalanga Net Hub',
      province: 'Mpumalanga',
      city: 'Mbombela',
      address: 'Mbombela, Mpumalanga',
      summary: 'Regional hub for networking and digital literacy.',
      isActive: true,
      isRecruiting: true,
      recruitmentDates: 'Sep – Nov 2026',
      latitude: -25.4753,
      longitude: 30.9694,
      programmes: ['Networking Essentials', 'Digital Literacy'],
      events: [
        AcademyEvent(
          title: 'Centre open morning',
          dateLabel: '18 Sep 2026',
          description: 'Tour the labs and meet instructors.',
        ),
      ],
    ),
    Academy(
      id: 'ac-bloem',
      name: 'Free State Digital Bridge',
      province: 'Free State',
      city: 'Bloemfontein',
      address: 'Bloemfontein, Free State',
      summary: 'Free State academy for IT support pathways.',
      isActive: true,
      isRecruiting: false,
      latitude: -29.0852,
      longitude: 26.1596,
      programmes: ['IT Customer Support Basics'],
      events: const [],
    ),
  ];

  @override
  Future<List<String>> getProvinces() async => provinces;

  @override
  Future<List<Academy>> getAcademies({String? province}) async {
    if (province == null || province.isEmpty || province == 'All') {
      return List.unmodifiable(_academies);
    }
    return _academies.where((a) => a.province == province).toList(growable: false);
  }

  @override
  Future<Academy?> getById(String id) async {
    try {
      return _academies.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> registerInterest({
    required String academyId,
    required String fullName,
    required String email,
    required String phone,
    required String notes,
  }) async {
    // ignore: avoid_print
    print('ACADEMY INTEREST: $academyId | $fullName | $email | $phone | $notes');
  }

  @override
  Future<void> registerOrganisation({
    required String organisationName,
    required String contactName,
    required String email,
    required String phone,
    required String province,
  }) async {
    // ignore: avoid_print
    print(
      'ORG REGISTER: $organisationName | $contactName | $email | $phone | $province',
    );
  }
}

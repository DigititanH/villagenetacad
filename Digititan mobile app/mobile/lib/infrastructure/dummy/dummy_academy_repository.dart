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
      summary: 'Community tech academy focused on IT support and networking pathways.',
      isActive: true,
      isRecruiting: true,
      recruitmentDates: '1 Sep 2026 – 30 Sep 2026',
      coursesOffered: ['Networking Basics', 'IT Customer Support Basics', 'Cyber Intro'],
    ),
    Academy(
      id: 'ac-soweto',
      name: 'Soweto Digital Hub',
      province: 'Gauteng',
      city: 'Soweto',
      summary: 'Youth digital skills hub with self-paced and contact training options.',
      isActive: true,
      isRecruiting: true,
      recruitmentDates: '15 Aug 2026 – 15 Oct 2026',
      coursesOffered: ['Python Essentials', 'Digital Literacy'],
    ),
    Academy(
      id: 'ac-cpt',
      name: 'Cape Flats NetAcad Centre',
      province: 'Western Cape',
      city: 'Cape Town',
      summary: 'Cisco-aligned networking centre supporting local beneficiaries.',
      isActive: true,
      isRecruiting: false,
      coursesOffered: ['CCNA Intro', 'Networking Essentials'],
    ),
    Academy(
      id: 'ac-dbn',
      name: 'eThekwini Skills Academy',
      province: 'KwaZulu-Natal',
      city: 'Durban',
      summary: 'Coastal academy offering cyber and support pathways.',
      isActive: true,
      isRecruiting: true,
      recruitmentDates: 'Rolling intake',
      coursesOffered: ['Introduction to Cybersecurity', 'Endpoint Security'],
    ),
    Academy(
      id: 'ac-pe',
      name: 'Gqeberha Tech Bridge',
      province: 'Eastern Cape',
      city: 'Gqeberha',
      summary: 'Bridge programme for first-time IT learners.',
      isActive: false,
      isRecruiting: false,
      coursesOffered: ['Computer Hardware Basics'],
    ),
    Academy(
      id: 'ac-polokwane',
      name: 'Limpopo Future Coders',
      province: 'Limpopo',
      city: 'Polokwane',
      summary: 'Programming and digital literacy for rural youth outreach.',
      isActive: true,
      isRecruiting: true,
      recruitmentDates: 'Oct 2026',
      coursesOffered: ['Python Essentials', 'Digital Awareness'],
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
      'ORG REGISTRATION: $organisationName | $contactName | $email | $phone | $province',
    );
  }
}

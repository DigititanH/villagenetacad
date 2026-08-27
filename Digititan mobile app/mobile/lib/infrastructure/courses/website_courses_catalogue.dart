import '../../domain/entities/training_offer.dart';

/// Hardcoded Village NetAcad courses — mirrors live website `/courses` (Aug 2026).
/// Not loaded from MySQL. Free → Cisco; paid CCNA → website `/courses/enrol`.
class WebsiteCoursesCatalogue {
  WebsiteCoursesCatalogue._();

  static String _idFromTitle(String title) {
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return 'course-$slug';
  }

  static final List<TrainingOffer> offers = [
    TrainingOffer(
      id: _idFromTitle('CCNA 1, 2 and 3'),
      title: 'CCNA 1, 2 and 3',
      category: 'Networking',
      level: 'Intermediate',
      hours: 210,
      summary:
          'Complete the full CCNA pathway with Village NetAcad. Subscribe '
          'monthly and work through all three Cisco modules to prepare for '
          'the CCNA certification.',
      priceLabel: 'R550/mo',
      isPaidOnWebsite: true,
      recruitmentOpen: true,
    ),
    TrainingOffer(
      id: _idFromTitle('Using Computer and Mobile Devices'),
      title: 'Using Computer and Mobile Devices',
      category: 'Digital Literacy',
      level: 'Beginner',
      hours: 6,
      summary:
          'Learn the basic skills to use computers and mobile devices '
          'effectively to access online services.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/computer-mobile-devices?courseLang=en-US&instance_id=4d26c6a9-d255-4974-95cc-013ae65c003f',
    ),
    TrainingOffer(
      id: _idFromTitle('Digital Awareness'),
      title: 'Digital Awareness',
      category: 'Digital Literacy',
      level: 'Beginner',
      hours: 6,
      summary:
          'Practical digital skills you can apply at home, school or work '
          'and how to stay safe online.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/digital-safety-security?courseLang=en-US&instance_id=2db98653-3873-44e1-bb1b-ec23f4b72c9f',
    ),
    TrainingOffer(
      id: _idFromTitle('Digital Safety and Security Awareness'),
      title: 'Digital Safety and Security Awareness',
      category: 'Digital Literacy',
      level: 'Beginner',
      hours: 6,
      summary:
          'Gain essential skills to protect your personal data, navigate '
          'online threats and ensure your digital well-being.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/digital-safety-security?courseLang=en-US&instance_id=2e7e396f-68b9-4463-8231-d524375e2287',
    ),
    TrainingOffer(
      id: _idFromTitle('Create Digital Content, Communicate and Collaborate Online'),
      title: 'Create Digital Content, Communicate and Collaborate Online',
      category: 'Digital Literacy',
      level: 'Beginner',
      hours: 6,
      summary:
          'Create digital documents and practice using collaborative tools '
          'to work effectively in hybrid and remote settings.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/create-communicate-collaborate?courseLang=en-US&instance_id=6951f9b5-1bbb-44b0-af3d-00bd4542d2d5',
    ),
    TrainingOffer(
      id: _idFromTitle('Introduction to IoT and Digital Transformation'),
      title: 'Introduction to IoT and Digital Transformation',
      category: 'Digital Literacy',
      level: 'Beginner',
      hours: 6,
      summary:
          'Billions of devices connect to the network every day. Learn how '
          'IoT is digitally transforming the world.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/introduction-iot?courseLang=en-US&instance_id=ecb1c5f2-260b-47a4-ad14-a7ea6edc64d2',
    ),
    TrainingOffer(
      id: _idFromTitle('Networking Basics'),
      title: 'Networking Basics',
      category: 'Networking',
      level: 'Beginner',
      hours: 22,
      summary:
          'Discover what a network is, how it works and how to design, build '
          'and operate small home and office networks.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/networking-basics?courseLang=en-US&instance_id=272bd6af-11c1-42e7-ac2c-6c4435d02724',
    ),
    TrainingOffer(
      id: _idFromTitle('Introduction to Cybersecurity'),
      title: 'Introduction to Cybersecurity',
      category: 'Cybersecurity',
      level: 'Beginner',
      hours: 6,
      summary:
          'Explore the exciting field of cybersecurity and why cybersecurity '
          'is a future-proof career.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/introduction-to-cybersecurity?courseLang=en-US&instance_id=3c76967e-c11d-4214-8654-7cd5236411bf',
    ),
    TrainingOffer(
      id: _idFromTitle('Introduction to Modern AI'),
      title: 'Introduction to Modern AI',
      category: 'AI',
      level: 'Beginner',
      hours: 6,
      summary:
          'Learn key AI concepts and get hands-on practice with AI-enabled '
          'apps. Explore computer vision, machine translation and writing '
          'better prompts for chatbots like ChatGPT, Gemini and Claude.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/introduction-to-modern-ai?courseLang=en-US&instance_id=738330a5-8ab7-40b4-a389-3a936683f452',
    ),
    TrainingOffer(
      id: _idFromTitle('IT Customer Support Basics'),
      title: 'IT Customer Support Basics',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 4,
      summary:
          'Develop help desk and customer support skills to succeed in '
          'entry-level IT positions and troubleshoot common issues.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/it-customer-support-basics?courseLang=en-US&instance_id=990fec27-2015-40d1-808e-68d5ec08afec',
    ),
    TrainingOffer(
      id: _idFromTitle('Computer Hardware Basics'),
      title: 'Computer Hardware Basics',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 6,
      summary:
          'Start learning the basics of computer hardware and discover the '
          'components of PCs, laptops and mobile devices.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/computer-hardware-basics?courseLang=en-US&instance_id=989bdfa9-0215-4c4e-b7f8-f6da45b5760e',
    ),
    TrainingOffer(
      id: _idFromTitle('Linux Unhatched'),
      title: 'Linux Unhatched',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 8,
      summary:
          'A quick, hands-on introduction to the popular Linux operating '
          'system. It is perfect for first-time Linux learners.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/linux-unhatched?courseLang=en-US&instance_id=26859ae1-0d8d-4421-9e88-ff33cf2844e4',
    ),
    TrainingOffer(
      id: _idFromTitle('Hardware and Upgrade Support'),
      title: 'Hardware and Upgrade Support',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 6,
      summary:
          'Your hands-on guide to PC hardware. Learn to diagnose, repair and '
          'upgrade components to launch your IT career.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/hardware-upgrade-support?courseLang=en-US&instance_id=03391ca6-8d5a-4d0d-8572-25b0cd3a8549',
    ),
    TrainingOffer(
      id: _idFromTitle('Operating Systems Basics'),
      title: 'Operating Systems Basics',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 12,
      summary:
          'Start learning the basics of computer and mobile device operating '
          'systems and how they manage hardware and software.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/operating-systems-support?courseLang=en-US&instance_id=b1c890b0-297f-473b-a9ee-9608388af4cf',
    ),
    TrainingOffer(
      id: _idFromTitle('Operating Systems Support'),
      title: 'Operating Systems Support',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 10,
      summary:
          'Troubleshoot Windows, macOS and mobile systems. Improve your '
          'customer service skills and prepare for entry-level IT support roles.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/operating-systems-support?courseLang=en-US&instance_id=b1c890b0-297f-473b-a9ee-9608388af4cf',
    ),
    TrainingOffer(
      id: _idFromTitle('Security and Connectivity Support'),
      title: 'Security and Connectivity Support',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 10,
      summary:
          'Develop foundational IT support skills. Learn to troubleshoot '
          'connectivity and defend systems against modern cybersecurity threats.',
      priceLabel: 'Free',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/security-connectivity-support?courseLang=en-US&instance_id=929f2d7e-ba26-4089-b5cd-ef25cef46b2e',
    ),
  ];
}

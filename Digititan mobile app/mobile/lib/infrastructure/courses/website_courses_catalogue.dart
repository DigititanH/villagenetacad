import '../../domain/entities/training_offer.dart';

/// Hardcoded Village NetAcad courses — mirrors live website `/courses`.
///
/// Images match the live site: per-course `image` when set, otherwise the same
/// category Unsplash pool + title-hash picker used on villagenetacad.co.za.
class WebsiteCoursesCatalogue {
  WebsiteCoursesCatalogue._();

  static final List<TrainingOffer> offers = [
    TrainingOffer(
      id: 'course-ccna-1-2-and-3',
      title: 'CCNA 1, 2 and 3',
      category: 'Networking',
      level: 'Intermediate',
      hours: 210,
      summary:
          'Complete the full CCNA pathway with Village NetAcad. Subscribe monthly and work through all three Cisco modules to prepare for the CCNA certification.',
      priceLabel: 'R550/mo',
      imageUrl:
          'https://images.unsplash.com/photo-1551703599-6b3e8379aa8c?auto=format&fit=crop&w=900&q=80',
      isPaidOnWebsite: true,
      recruitmentOpen: true,
    ),
    TrainingOffer(
      id: 'course-using-computer-and-mobile-devices',
      title: 'Using Computer and Mobile Devices',
      category: 'Digital Literacy',
      level: 'Beginner',
      hours: 6,
      summary:
          'Learn the basic skills to use computers and mobile devices effectively to access online services.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/computer-mobile-devices?courseLang=en-US&instance_id=4d26c6a9-d255-4974-95cc-013ae65c003f',
    ),
    TrainingOffer(
      id: 'course-digital-awareness',
      title: 'Digital Awareness',
      category: 'Digital Literacy',
      level: 'Beginner',
      hours: 6,
      summary:
          'Practical digital skills you can apply at home, school or work and how to stay safe online.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/digital-safety-security?courseLang=en-US&instance_id=2db98653-3873-44e1-bb1b-ec23f4b72c9f',
    ),
    TrainingOffer(
      id: 'course-digital-safety-and-security-awareness',
      title: 'Digital Safety and Security Awareness',
      category: 'Digital Literacy',
      level: 'Beginner',
      hours: 6,
      summary:
          'Gain essential skills to protect your personal data, navigate online threats and ensure your digital well-being.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/digital-safety-security?courseLang=en-US&instance_id=2e7e396f-68b9-4463-8231-d524375e2287',
    ),
    TrainingOffer(
      id: 'course-create-digital-content-communicate-and-collaborate-online',
      title: 'Create Digital Content, Communicate and Collaborate Online',
      category: 'Digital Literacy',
      level: 'Beginner',
      hours: 6,
      summary:
          'Create digital documents and practice using collaborative tools to work effectively in hybrid and remote settings.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1432888498266-38ffec3eaf0a?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/create-communicate-collaborate?courseLang=en-US&instance_id=6951f9b5-1bbb-44b0-af3d-00bd4542d2d5',
    ),
    TrainingOffer(
      id: 'course-introduction-to-iot-and-digital-transformation',
      title: 'Introduction to IoT and Digital Transformation',
      category: 'Digital Literacy',
      level: 'Beginner',
      hours: 6,
      summary:
          'Billions of devices connect to the network every day. Learn how IoT is digitally transforming the world.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/introduction-iot?courseLang=en-US&instance_id=ecb1c5f2-260b-47a4-ad14-a7ea6edc64d2',
    ),
    TrainingOffer(
      id: 'course-networking-basics',
      title: 'Networking Basics',
      category: 'Networking',
      level: 'Beginner',
      hours: 22,
      summary:
          'Discover what a network is, how it works and how to design, build and operate small home and office networks.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/networking-basics?courseLang=en-US&instance_id=272bd6af-11c1-42e7-ac2c-6c4435d02724',
    ),
    TrainingOffer(
      id: 'course-introduction-to-cybersecurity',
      title: 'Introduction to Cybersecurity',
      category: 'Cybersecurity',
      level: 'Beginner',
      hours: 6,
      summary:
          'Explore the exciting field of cybersecurity and why cybersecurity is a future-proof career.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/introduction-to-cybersecurity?courseLang=en-US&instance_id=3c76967e-c11d-4214-8654-7cd5236411bf',
    ),
    TrainingOffer(
      id: 'course-introduction-to-modern-ai',
      title: 'Introduction to Modern AI',
      category: 'AI',
      level: 'Beginner',
      hours: 6,
      summary:
          'Learn key AI concepts and get hands-on practice with AI-enabled apps. Explore computer vision, machine translation and writing better prompts for chatbots like ChatGPT, Gemini and Claude.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/introduction-to-modern-ai?courseLang=en-US&instance_id=738330a5-8ab7-40b4-a389-3a936683f452',
    ),
    TrainingOffer(
      id: 'course-it-customer-support-basics',
      title: 'IT Customer Support Basics',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 4,
      summary:
          'Develop help desk and customer support skills to succeed in entry-level IT positions and troubleshoot common issues.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1614624532983-4ce03382d63d?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/it-customer-support-basics?courseLang=en-US&instance_id=990fec27-2015-40d1-808e-68d5ec08afec',
    ),
    TrainingOffer(
      id: 'course-computer-hardware-basics',
      title: 'Computer Hardware Basics',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 6,
      summary:
          'Start learning the basics of computer hardware and discover the components of PCs, laptops and mobile devices.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1531297484001-80022131f5a1?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/computer-hardware-basics?courseLang=en-US&instance_id=989bdfa9-0215-4c4e-b7f8-f6da45b5760e',
    ),
    TrainingOffer(
      id: 'course-linux-unhatched',
      title: 'Linux Unhatched',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 8,
      summary:
          'A quick, hands-on introduction to the popular Linux operating system. It is perfect for first-time Linux learners.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1614624532983-4ce03382d63d?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/linux-unhatched?courseLang=en-US&instance_id=26859ae1-0d8d-4421-9e88-ff33cf2844e4',
    ),
    TrainingOffer(
      id: 'course-hardware-and-upgrade-support',
      title: 'Hardware and Upgrade Support',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 6,
      summary:
          'Your hands-on guide to PC hardware. Learn to diagnose, repair and upgrade components to launch your IT career.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/hardware-upgrade-support?courseLang=en-US&instance_id=03391ca6-8d5a-4d0d-8572-25b0cd3a8549',
    ),
    TrainingOffer(
      id: 'course-operating-systems-basics',
      title: 'Operating Systems Basics',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 12,
      summary:
          'Start learning the basics of computer and mobile device operating systems and how they manage hardware and software.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1531297484001-80022131f5a1?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/operating-systems-support?courseLang=en-US&instance_id=b1c890b0-297f-473b-a9ee-9608388af4cf',
    ),
    TrainingOffer(
      id: 'course-operating-systems-support',
      title: 'Operating Systems Support',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 10,
      summary:
          'Troubleshoot Windows, macOS and mobile systems. Improve your customer service skills and prepare for entry-level IT support roles.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/operating-systems-support?courseLang=en-US&instance_id=b1c890b0-297f-473b-a9ee-9608388af4cf',
    ),
    TrainingOffer(
      id: 'course-security-and-connectivity-support',
      title: 'Security and Connectivity Support',
      category: 'IT Essentials',
      level: 'Beginner',
      hours: 10,
      summary:
          'Develop foundational IT support skills. Learn to troubleshoot connectivity and defend systems against modern cybersecurity threats.',
      priceLabel: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1531297484001-80022131f5a1?auto=format&fit=crop&w=900&q=80',
      ciscoEnrollUrl:
          'https://www.netacad.com/courses/security-connectivity-support?courseLang=en-US&instance_id=929f2d7e-ba26-4089-b5cd-ef25cef46b2e',
    ),
  ];
}

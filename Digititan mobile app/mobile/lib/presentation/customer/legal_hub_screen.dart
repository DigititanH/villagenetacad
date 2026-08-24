import 'package:flutter/material.dart';

/// Meeting feedback: Terms, privacy (POPI), security, returns.
class LegalHubScreen extends StatelessWidget {
  const LegalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Terms and conditions',
        'By using Village NetAcad powered by Digititan you agree to programme '
            'rules, fair use of reseller codes, and accurate registration details. '
            'Digititan may suspend accounts that misuse referral codes or submit '
            'fraudulent claims.'
      ),
      (
        'Privacy & user data (POPI)',
        'We collect personal information (name, email, phone, gender for learners, '
            'organisation details) to run training interest, shop fulfilment, LMS '
            'alignment, and reseller payouts. Under South Africa\'s Protection of '
            'Personal Information Act (POPI) we process data for these stated '
            'purposes, keep it secure, and do not sell it. You may request access '
            'or correction via Digititan support.'
      ),
      (
        'Security',
        'We use HTTPS, hashed passwords, OTP (email/SMS), role-based access, and '
            'PayFast for card payments. Never share OTPs. Digititan staff will not '
            'ask for your password. Report suspicious reseller codes using Verify '
            'reseller in the app.'
      ),
      (
        'Returns policy',
        'Physical products: return within 7 days after delivery if unused and in '
            'original packaging (locked product decision). Digital / training fees '
            'follow the offer terms stated at purchase. Contact Digititan support '
            'to start a return.'
      ),
      (
        'POPI Act summary',
        'You have the right to know what we hold, correct it, and object to '
            'unnecessary processing. Operators such as PayFast and SMS providers '
            'process data only to deliver payments and OTPs under our instructions.'
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Legal & privacy')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final item = items[i];
          return ExpansionTile(
            title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            children: [
              Text(item.$2, style: const TextStyle(height: 1.45)),
            ],
          );
        },
      ),
    );
  }
}

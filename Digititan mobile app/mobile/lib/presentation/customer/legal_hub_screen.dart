import 'package:flutter/material.dart';

/// Wave 1 meeting feedback: draft legal pages.
/// POPI Act full compliance copy comes later (lawyer review).
class LegalHubScreen extends StatelessWidget {
  const LegalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      (
        'Terms and conditions',
        'By using Village NetAcad powered by Digititan you agree to programme '
            'rules, fair use of reseller codes, and accurate registration details. '
            'Digititan may suspend accounts that misuse referral codes or submit '
            'fraudulent claims. Draft — final wording before launch.',
      ),
      (
        'Privacy & user data',
        'We collect personal information (name, email, phone, organisation '
            'details) to run training interest, shop fulfilment, and reseller '
            'payouts. We do not sell your data. You may request access or '
            'correction via Digititan support. Draft — POPI Act detail later.',
      ),
      (
        'Security',
        'We use HTTPS, hashed passwords, OTP verification, role-based access, '
            'and a payment gateway for card payments. Never share OTPs. Digititan '
            'staff will not ask for your password.',
      ),
      (
        'Returns policy',
        'Physical products: return within 7 days after delivery if unused and in '
            'original packaging. Digital / training fees follow the offer terms '
            'stated at purchase. Contact Digititan support to start a return.',
      ),
      (
        'POPI Act (later)',
        'Full POPI Act wording and operator agreements will be added after legal '
            'review. Until then this draft privacy notice applies.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Legal & privacy')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final item = items[i];
          return ExpansionTile(
            title: Text(
              item.$1,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
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

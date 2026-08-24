import 'package:flutter/material.dart';

import '../../shared/config/app_config.dart';

enum OtpChannel { email, sms }

/// Meeting feedback: OTP via email or SMS.
class OtpChannelPicker extends StatelessWidget {
  final OtpChannel value;
  final ValueChanged<OtpChannel> onChanged;
  final String? phoneHint;

  const OtpChannelPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.phoneHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Send OTP via', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Email'),
              selected: value == OtpChannel.email,
              onSelected: (_) => onChanged(OtpChannel.email),
            ),
            ChoiceChip(
              label: const Text('SMS'),
              selected: value == OtpChannel.sms,
              onSelected: (_) => onChanged(OtpChannel.sms),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value == OtpChannel.email
              ? 'Demo email OTP: ${AppConfig.emailOtpDemo}'
              : 'Demo SMS OTP: ${AppConfig.smsOtpDemo}'
                  '${phoneHint == null || phoneHint!.isEmpty ? '' : ' · $phoneHint'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

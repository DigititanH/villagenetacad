import 'package:flutter/material.dart';

import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';

enum OtpChannel { email, sms }

class OtpChannelPicker extends StatelessWidget {
  final OtpChannel selected;
  final ValueChanged<OtpChannel> onChanged;

  const OtpChannelPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  String get _demoCode =>
      selected == OtpChannel.email ? AppConfig.emailOtpDemo : AppConfig.smsOtpDemo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receive OTP via',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Email'),
              selected: selected == OtpChannel.email,
              onSelected: (_) => onChanged(OtpChannel.email),
              selectedColor: DigititanColors.accent.withOpacity(0.25),
            ),
            ChoiceChip(
              label: const Text('SMS'),
              selected: selected == OtpChannel.sms,
              onSelected: (_) => onChanged(OtpChannel.sms),
              selectedColor: DigititanColors.accent.withOpacity(0.25),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Prototype demo code: $_demoCode',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DigititanColors.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

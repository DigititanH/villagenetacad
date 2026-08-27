import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../shared/config/app_config.dart';
import '../../shared/result/result.dart';
import '../../shared/theme/digititan_theme.dart';
import 'otp_channel_picker.dart';

class OtpScreen extends StatefulWidget {
  final AppContainer container;
  final String email;

  const OtpScreen({
    super.key,
    required this.container,
    required this.email,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  OtpChannel _channel = OtpChannel.email;
  late final TextEditingController _otp;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _otp = TextEditingController(text: AppConfig.emailOtpDemo);
  }

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  void _onChannelChanged(OtpChannel channel) {
    setState(() {
      _channel = channel;
      _otp.text = channel == OtpChannel.email
          ? AppConfig.emailOtpDemo
          : AppConfig.smsOtpDemo;
    });
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.container.verifyEmailOtp(
      email: widget.email,
      otp: _otp.text,
    );
    setState(() => _loading = false);

    switch (result) {
      case Success(:final data):
        if (mounted) Navigator.of(context).pop(data);
      case Failure(:final message):
        setState(() => _error = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final channelLabel = _channel == OtpChannel.email ? 'email' : 'SMS';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('We sent an OTP to ${widget.email} via $channelLabel.'),
            const SizedBox(height: 16),
            OtpChannelPicker(
              selected: _channel,
              onChanged: _onChannelChanged,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otp,
              decoration: const InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _verify,
              child: Text(_loading ? 'Verifying…' : 'Verify & continue'),
            ),
          ],
        ),
      ),
    );
  }
}

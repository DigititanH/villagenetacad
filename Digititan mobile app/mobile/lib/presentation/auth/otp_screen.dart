import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../shared/result/result.dart';
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
  final _otp = TextEditingController(text: '123456');
  OtpChannel _channel = OtpChannel.email;
  bool _loading = false;
  String? _error;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _channel == OtpChannel.email
                  ? 'We sent an OTP to ${widget.email}'
                  : 'We sent an SMS OTP to your registered phone',
            ),
            const SizedBox(height: 12),
            OtpChannelPicker(
              value: _channel,
              onChanged: (c) => setState(() => _channel = c),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otp,
              decoration: const InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _verify,
              child: Text(_loading ? 'Verifying...' : 'Verify & continue'),
            ),
          ],
        ),
      ),
    );
  }
}

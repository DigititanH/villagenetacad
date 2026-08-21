import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/training_offer.dart';
import '../../domain/entities/user.dart';
import '../../shared/result/result.dart';

class RegisterInterestScreen extends StatefulWidget {
  final AppContainer container;
  final User user;
  final TrainingOffer training;

  const RegisterInterestScreen({
    super.key,
    required this.container,
    required this.user,
    required this.training,
  });

  @override
  State<RegisterInterestScreen> createState() => _RegisterInterestScreenState();
}

class _RegisterInterestScreenState extends State<RegisterInterestScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _phone = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user.name);
    _email = TextEditingController(text: widget.user.email);
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.container.registerTrainingInterest(
      trainingId: widget.training.id,
      fullName: _name.text,
      email: _email.text,
      phone: _phone.text,
    );
    setState(() => _loading = false);

    switch (result) {
      case Success():
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Interest registered'),
            content: Text(
              'Thanks. We recorded your interest in "${widget.training.title}".\n'
              '(Prototype: also printed in flutter console.)',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.pop(context);
      case Failure(:final message):
        setState(() => _error = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register interest')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(widget.training.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
              keyboardType: TextInputType.phone,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Submitting...' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

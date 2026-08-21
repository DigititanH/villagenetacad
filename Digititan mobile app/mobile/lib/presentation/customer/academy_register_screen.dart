import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/academy.dart';
import '../../domain/entities/user.dart';
import '../../shared/result/result.dart';

class AcademyRegisterScreen extends StatefulWidget {
  final AppContainer container;
  final User user;
  final Academy academy;

  const AcademyRegisterScreen({
    super.key,
    required this.container,
    required this.user,
    required this.academy,
  });

  @override
  State<AcademyRegisterScreen> createState() => _AcademyRegisterScreenState();
}

class _AcademyRegisterScreenState extends State<AcademyRegisterScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _phone = TextEditingController();
  final _notes = TextEditingController();
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
    final result = await widget.container.registerAcademyInterest(
      academyId: widget.academy.id,
      fullName: _name.text,
      email: _email.text,
      phone: _phone.text,
      notes: _notes.text,
    );
    setState(() => _loading = false);

    switch (result) {
      case Success():
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Application submitted'),
            content: Text(
              'Your application to ${widget.academy.name} was recorded.\n'
              '(Prototype: printed in flutter console.)',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
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
      appBar: AppBar(title: const Text('Academy registration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(widget.academy.name, style: Theme.of(context).textTheme.titleMedium),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full name')),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes / programme interest'),
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Submitting...' : 'Submit application'),
            ),
          ],
        ),
      ),
    );
  }
}

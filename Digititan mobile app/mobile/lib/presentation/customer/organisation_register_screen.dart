import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../infrastructure/dummy/dummy_academy_repository.dart';
import '../../shared/result/result.dart';

class OrganisationRegisterScreen extends StatefulWidget {
  final AppContainer container;

  const OrganisationRegisterScreen({super.key, required this.container});

  @override
  State<OrganisationRegisterScreen> createState() => _OrganisationRegisterScreenState();
}

class _OrganisationRegisterScreenState extends State<OrganisationRegisterScreen> {
  final _org = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _province = DummyAcademyRepository.provinces.first;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.container.registerAcademyOrganisation(
      organisationName: _org.text,
      contactName: _contact.text,
      email: _email.text,
      phone: _phone.text,
      province: _province,
    );
    setState(() => _loading = false);

    switch (result) {
      case Success():
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Organisation submitted'),
            content: const Text(
              'Organisation / academy registration captured for Digititan review.\n'
              'Ops Admin will see your details in the queue. Cisco onboarding can follow after we have your record.',
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
      appBar: AppBar(title: const Text('Register NPO / Academy')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Register your academy / NPO with Digititan first.\n'
              'We capture your details in our database so Ops can review '
              'and support you. Cisco NetAcad onboarding can follow later — '
              'do not only register on Cisco or we lose visibility of your organisation.',
            ),
            TextField(
              controller: _org,
              decoration: const InputDecoration(labelText: 'Organisation / academy name'),
            ),
            TextField(
              controller: _contact,
              decoration: const InputDecoration(labelText: 'Contact person'),
            ),
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
            const SizedBox(height: 8),
            const Text('Province'),
            DropdownButton<String>(
              value: _province,
              isExpanded: true,
              items: DummyAcademyRepository.provinces
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _province = v ?? _province),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Submitting...' : 'Submit to Digititan'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../infrastructure/dummy/dummy_academy_repository.dart';
import '../../shared/result/result.dart';

/// Wave 1: academies/orgs register with Digititan first (not Cisco-only).
class OrganisationRegisterScreen extends StatefulWidget {
  final AppContainer container;

  const OrganisationRegisterScreen({super.key, required this.container});

  @override
  State<OrganisationRegisterScreen> createState() =>
      _OrganisationRegisterScreenState();
}

class _OrganisationRegisterScreenState
    extends State<OrganisationRegisterScreen> {
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
            title: const Text('Submitted to Digititan'),
            content: const Text(
              'Your academy / organisation details are saved for Digititan '
              'review. Ops Admin can see this lead.\n\n'
              'Cisco NetAcad onboarding can follow later — we register with '
              'Digititan first so we do not lose your details.',
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
      appBar: AppBar(title: const Text('Register academy / org')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Register with Digititan first',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'If you only register on Cisco, Digititan will not see your '
              'academy. Submit here so we capture your organisation details. '
              'Cisco NetAcad setup can happen after Ops reviews your application.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _org,
              decoration: const InputDecoration(
                labelText: 'Organisation / academy name',
              ),
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
              child: Text(
                _loading ? 'Submitting...' : 'Submit to Digititan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

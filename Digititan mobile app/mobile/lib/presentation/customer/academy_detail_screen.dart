import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/academy.dart';
import '../../domain/entities/user.dart';
import 'academy_register_screen.dart';

class AcademyDetailScreen extends StatefulWidget {
  final AppContainer container;
  final User user;
  final String academyId;

  const AcademyDetailScreen({
    super.key,
    required this.container,
    required this.user,
    required this.academyId,
  });

  @override
  State<AcademyDetailScreen> createState() => _AcademyDetailScreenState();
}

class _AcademyDetailScreenState extends State<AcademyDetailScreen> {
  Academy? _academy;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final academy =
        await widget.container.academyRepository.getById(widget.academyId);
    if (!mounted) return;
    setState(() {
      _academy = academy;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academy')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _academy == null
              ? const Center(child: Text('Academy not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(_academy!.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('${_academy!.city}, ${_academy!.province}'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(_academy!.isActive ? 'Active' : 'Inactive')),
                        if (_academy!.isRecruiting)
                          const Chip(label: Text('Recruiting')),
                      ],
                    ),
                    if (_academy!.recruitmentDates != null) ...[
                      const SizedBox(height: 8),
                      Text('Recruitment: ${_academy!.recruitmentDates}'),
                    ],
                    const SizedBox(height: 16),
                    Text(_academy!.summary),
                    const SizedBox(height: 16),
                    Text('Courses offered', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ..._academy!.coursesOffered.map(
                      (c) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(c),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AcademyRegisterScreen(
                              container: widget.container,
                              user: widget.user,
                              academy: _academy!,
                            ),
                          ),
                        );
                      },
                      child: const Text('Register / apply to academy'),
                    ),
                  ],
                ),
    );
  }
}

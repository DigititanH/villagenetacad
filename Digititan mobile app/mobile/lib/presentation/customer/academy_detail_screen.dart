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
                    Text(
                      _academy!.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.place, size: 18, color: Color(0xFFC62828)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${_academy!.address}\n'
                            '${_academy!.city}, ${_academy!.province}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Map pin: ${_academy!.latitude.toStringAsFixed(4)}, '
                      '${_academy!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
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
                    const SizedBox(height: 20),
                    Text('Programmes', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_academy!.programmes.isEmpty)
                      const Text('No programmes listed yet.')
                    else
                      ..._academy!.programmes.map(
                        (c) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.school_outlined),
                          title: Text(c),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'Events hosting',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_academy!.events.isEmpty)
                      const Text('No upcoming events listed yet.')
                    else
                      ..._academy!.events.map(
                        (e) => Card(
                          child: ListTile(
                            title: Text(e.title),
                            subtitle: Text('${e.dateLabel}\n${e.description}'),
                            isThreeLine: true,
                            leading: const Icon(Icons.event),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (!_academy!.isActive)
                      const Text(
                        'This academy is inactive — registration is closed.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                    else
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

import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/academy.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/result/result.dart';
import '../academy_detail_screen.dart';
import '../academy_performance_screen.dart';
import '../organisation_register_screen.dart';
import '../widgets/south_africa_academies_map.dart';

/// Meeting requirement:
/// SA map -> tap province -> academy list (+ pins) -> academy detail
/// (events, programmes, location).
class AcademiesTab extends StatefulWidget {
  final AppContainer container;
  final User user;

  const AcademiesTab({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  State<AcademiesTab> createState() => _AcademiesTabState();
}

class _AcademiesTabState extends State<AcademiesTab> {
  String? _province;
  /// all | active | inactive
  String _statusFilter = 'all';
  List<Academy> _all = [];
  List<Academy> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.container.getAcademies();
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _all = data;
          _applyFilter();
        case Failure(:final message):
          _error = message;
      }
    });
  }

  void _applyFilter() {
    Iterable<Academy> list = _all;
    if (_province != null && _province != 'All') {
      list = list.where((a) => a.province == _province);
    }
    if (_statusFilter == 'active') {
      list = list.where((a) => a.isActive);
    } else if (_statusFilter == 'inactive') {
      list = list.where((a) => !a.isActive);
    }
    _filtered = list.toList();
  }

  void _selectProvince(String province) {
    setState(() {
      _province = province;
      _applyFilter();
    });
  }

  void _openAcademy(Academy a) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AcademyDetailScreen(
          container: widget.container,
          user: widget.user,
          academyId: a.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academies'),
        actions: [
          IconButton(
            tooltip: 'Academy performance / rankings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AcademyPerformanceScreen(),
                ),
              );
            },
            icon: const Icon(Icons.leaderboard_outlined),
          ),
          if (_province != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _province = null;
                  _applyFilter();
                });
              },
              child: const Text('All SA'),
            ),
          IconButton(
            tooltip: 'Register academy / org with Digititan',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrganisationRegisterScreen(
                    container: widget.container,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_business_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        _province == null
                            ? 'South Africa map — tap a province (red pins = academies)'
                            : '$_province — tap a pin or an academy below',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SouthAfricaAcademiesMap(
                        selectedProvince: _province,
                        academies: _all,
                        onProvinceSelected: _selectProvince,
                        onAcademySelected: _openAcademy,
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _statusFilter == 'all',
                            onSelected: (_) => setState(() {
                              _statusFilter = 'all';
                              _applyFilter();
                            }),
                          ),
                          ChoiceChip(
                            label: const Text('Active'),
                            selected: _statusFilter == 'active',
                            onSelected: (_) => setState(() {
                              _statusFilter = 'active';
                              _applyFilter();
                            }),
                          ),
                          ChoiceChip(
                            label: const Text('Inactive'),
                            selected: _statusFilter == 'inactive',
                            onSelected: (_) => setState(() {
                              _statusFilter = 'inactive';
                              _applyFilter();
                            }),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                      child: Text(
                        _province == null
                            ? 'Academies (${_filtered.length})'
                            : 'Academies in $_province (${_filtered.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: _filtered.isEmpty
                          ? const Center(
                              child: Text('No academies match this filter.'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _filtered.length,
                              itemBuilder: (context, i) {
                                final a = _filtered[i];
                                return Card(
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color: a.isActive
                                          ? const Color(0xFFC62828)
                                          : Colors.grey,
                                    ),
                                    title: Text(a.name),
                                    subtitle: Text(
                                      '${a.city}, ${a.province}\n'
                                      '${a.isActive ? 'Active' : 'Inactive'}'
                                      '${a.isRecruiting ? ' · Recruiting' : ''}'
                                      ' · ${a.events.length} event(s)',
                                    ),
                                    isThreeLine: true,
                                    trailing: Chip(
                                      label: Text(
                                        a.isActive ? 'Active' : 'Inactive',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: a.isActive
                                          ? const Color(0xFF2C9F58).withValues(alpha: 0.15)
                                          : Colors.grey.shade200,
                                    ),
                                    onTap: () => _openAcademy(a),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

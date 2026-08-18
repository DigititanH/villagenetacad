import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/academy.dart';
import '../../../domain/entities/user.dart';
import '../../../infrastructure/dummy/dummy_academy_repository.dart';
import '../../../shared/result/result.dart';
import '../academy_detail_screen.dart';
import '../organisation_register_screen.dart';

/// Province picker acts as the prototype "map" step from the meeting.
/// Real Google Map can replace this later without changing domain.
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
  String _province = 'All';
  List<Academy> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.container.getAcademies(
      province: _province == 'All' ? null : _province,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _items = data;
        case Failure(:final message):
          _error = message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provinces = ['All', ...DummyAcademyRepository.provinces];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academies'),
        actions: [
          IconButton(
            tooltip: 'Register NPO / Academy',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'South Africa map (prototype): choose a province',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: provinces
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(p),
                        selected: _province == p,
                        onSelected: (_) {
                          setState(() => _province = p);
                          _load();
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _items.isEmpty
                        ? const Center(child: Text('No academies in this province yet.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _items.length,
                            itemBuilder: (context, i) {
                              final a = _items[i];
                              return Card(
                                child: ListTile(
                                  title: Text(a.name),
                                  subtitle: Text(
                                    '${a.city}, ${a.province}\n'
                                    '${a.isActive ? 'Active' : 'Inactive'}'
                                    '${a.isRecruiting ? ' · Recruiting' : ''}',
                                  ),
                                  isThreeLine: true,
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AcademyDetailScreen(
                                          container: widget.container,
                                          user: widget.user,
                                          academyId: a.id,
                                        ),
                                      ),
                                    );
                                  },
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

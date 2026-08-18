import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/programme_highlight.dart';
import '../../../domain/entities/training_offer.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/result/result.dart';
import '../training_detail_screen.dart';

class HomeTab extends StatefulWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onOpenTraining;

  const HomeTab({
    super.key,
    required this.container,
    required this.user,
    required this.onOpenTraining,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<ProgrammeHighlight> _programmes = [];
  List<TrainingOffer> _offers = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final programmesResult = await widget.container.getProgrammes();
    final offersResult = await widget.container.getTrainingOffers();
    if (!mounted) return;

    setState(() {
      _loading = false;
      switch (programmesResult) {
        case Success(:final data):
          _programmes = data;
        case Failure(:final message):
          _error = message;
      }
      switch (offersResult) {
        case Success(:final data):
          _offers = data.take(3).toList();
        case Failure(:final message):
          _error ??= message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Hi ${widget.user.name.split(' ').first},',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                const Text('Home hub — programmes, training, store previews.'),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                Text('Current programmes', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._programmes.map(
                  (p) => Card(
                    child: ListTile(
                      title: Text(p.title),
                      subtitle: Text(p.subtitle),
                      trailing: p.isRecruiting
                          ? const Chip(label: Text('Recruiting'))
                          : null,
                      onTap: widget.onOpenTraining,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Featured training', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    TextButton(onPressed: widget.onOpenTraining, child: const Text('See all')),
                  ],
                ),
                ..._offers.map(
                  (o) => Card(
                    child: ListTile(
                      title: Text(o.title),
                      subtitle: Text('${o.category} · ${o.level} · ${o.hours}h'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TrainingDetailScreen(
                              container: widget.container,
                              user: widget.user,
                              trainingId: o.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Card(
                  child: ListTile(
                    title: Text('Best sellers / Promotions'),
                    subtitle: Text('Sample products in Store tab. Full shopping opens Digititan Store website.'),
                  ),
                ),
                const Card(
                  child: ListTile(
                    title: Text('Academies'),
                    subtitle: Text('Map + academy list arrive in Sprint 3.'),
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/training_offer.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/result/result.dart';
import '../training_detail_screen.dart';

class TrainingTab extends StatefulWidget {
  final AppContainer container;
  final User user;

  const TrainingTab({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  State<TrainingTab> createState() => _TrainingTabState();
}

class _TrainingTabState extends State<TrainingTab> {
  List<TrainingOffer> _offers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.container.getTrainingOffers();
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _offers = data;
        case Failure(:final message):
          _error = message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _offers.length,
                  itemBuilder: (context, i) {
                    final o = _offers[i];
                    return Card(
                      child: ListTile(
                        title: Text(o.title),
                        subtitle: Text(
                          '${o.category} · ${o.level} · ${o.hours}h'
                          '${o.recruitmentOpen ? ' · Recruiting' : ''}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
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
                    );
                  },
                ),
    );
  }
}

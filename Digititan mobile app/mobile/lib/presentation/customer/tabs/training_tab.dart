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
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: _offers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final o = _offers[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        o.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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
                    );
                  },
                ),
    );
  }
}

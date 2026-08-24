import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/training_offer.dart';
import '../../domain/entities/user.dart';
import 'register_interest_screen.dart';

class TrainingDetailScreen extends StatefulWidget {
  final AppContainer container;
  final User user;
  final String trainingId;

  const TrainingDetailScreen({
    super.key,
    required this.container,
    required this.user,
    required this.trainingId,
  });

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  TrainingOffer? _offer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = widget.container.trainingRepository;
    final offer = await repo.getOfferById(widget.trainingId);
    if (!mounted) return;
    setState(() {
      _offer = offer;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _offer == null
              ? const Center(child: Text('Training not found'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Text(_offer!.title, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('${_offer!.category} · ${_offer!.level} · ${_offer!.hours} hours'),
                      if (_offer!.recruitmentOpen) ...[
                        const SizedBox(height: 8),
                        const Chip(label: Text('Recruitment open')),
                      ],
                      const SizedBox(height: 16),
                      Text(_offer!.summary),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RegisterInterestScreen(
                                container: widget.container,
                                user: widget.user,
                                training: _offer!,
                              ),
                            ),
                          );
                        },
                        child: const Text('Register interest'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

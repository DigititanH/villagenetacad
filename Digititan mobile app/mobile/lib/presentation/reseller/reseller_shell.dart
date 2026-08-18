import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/injection.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/user.dart';

class ResellerShell extends StatefulWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onLogout;

  const ResellerShell({
    super.key,
    required this.container,
    required this.user,
    required this.onLogout,
  });

  @override
  State<ResellerShell> createState() => _ResellerShellState();
}

class _ResellerShellState extends State<ResellerShell> {
  ResellerProfile? _profile;
  List<ResellerClient> _clients = [];
  List<ResellerSale> _sales = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final email = widget.user.email;
      final profile = await widget.container.resellerRepository.getProfile(email);
      final clients = await widget.container.resellerRepository.getClients(email);
      final sales = await widget.container.resellerRepository.getSales(email);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _clients = clients;
        _sales = sales;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _showStatement() async {
    final text = await widget.container.resellerRepository
        .getMonthlyStatement(widget.user.email);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Monthly statement'),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _withdraw() async {
    final controller = TextEditingController(text: '200');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request withdrawal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (ZAR)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final amount = double.parse(controller.text);
      await widget.container.resellerRepository.requestWithdrawal(
        email: widget.user.email,
        amount: amount,
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal requested (prototype / needs approval)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reseller'),
          actions: [
            TextButton(
              onPressed: widget.onLogout,
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Clients'),
              Tab(text: 'Sales'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : TabBarView(
                    children: [
                      _dashboard(),
                      _clientsTab(),
                      _salesTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _dashboard() {
    final p = _profile!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Hi ${widget.user.name.split(' ').first}'),
        Text('Status: ${p.status}'),
        if (p.academyName != null) Text('Academy: ${p.academyName}'),
        const SizedBox(height: 12),
        ListTile(
          title: const Text('Referral code'),
          subtitle: Text(p.code),
          trailing: IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: p.code));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copied')),
              );
            },
          ),
        ),
        ListTile(title: const Text('Total earned'), subtitle: Text('R${p.totalEarned.toStringAsFixed(2)}')),
        ListTile(title: const Text('Balance (payable by Digititan)'), subtitle: Text('R${p.balance.toStringAsFixed(2)}')),
        ListTile(title: const Text('Commission rate'), subtitle: Text('${p.commissionRate}%')),
        const Text(
          'Money flow (locked): Digititan pays resellers.\n'
          'Withdrawals: end of month, with approval.\n'
          'Bank auto-debit: later (not V1).',
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: _showStatement, child: const Text('View monthly statement')),
        OutlinedButton(onPressed: _withdraw, child: const Text('Request month-end withdrawal')),
      ],
    );
  }

  Widget _clientsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _clients.length,
      itemBuilder: (context, i) {
        final c = _clients[i];
        return Card(
          child: ListTile(
            title: Text(c.name),
            subtitle: Text(
              '${c.email}\n'
              '${c.productInterest ?? '-'} · ${c.status.name}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _salesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _sales.length,
      itemBuilder: (context, i) {
        final s = _sales[i];
        return Card(
          child: ListTile(
            title: Text(s.productName),
            subtitle: Text('${s.clientName} · ${s.date.toIso8601String().substring(0, 10)}'),
            trailing: Text('+R${s.commission.toStringAsFixed(2)}'),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/injection.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/user.dart';
import '../../shared/widgets/demo_banner.dart';

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
        _error = null;
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
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
        const SnackBar(
          content: Text('Withdrawal requested (prototype / needs Super Admin)'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _addClient() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final interest = TextEditingController();
    var status = ResellerClientStatus.pending;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Add client / lead'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: interest,
                  decoration: const InputDecoration(
                    labelText: 'Product interest (optional)',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<ResellerClientStatus>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ResellerClientStatus.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setLocal(() => status = v ?? status),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty || email.text.trim().isEmpty) {
      return;
    }
    try {
      await widget.container.resellerRepository.addClient(
        resellerEmail: widget.user.email,
        name: name.text.trim(),
        email: email.text.trim(),
        productInterest: interest.text.trim(),
        status: status,
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client added')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _updateClientStatus(ResellerClient client) async {
    final status = await showDialog<ResellerClientStatus>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Update ${client.name}'),
        children: ResellerClientStatus.values
            .map(
              (s) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, s),
                child: Text(
                  s.name,
                  style: TextStyle(
                    fontWeight:
                        s == client.status ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (status == null || status == client.status) return;
    await widget.container.resellerRepository.updateClientStatus(
      resellerEmail: widget.user.email,
      clientId: client.id,
      status: status,
    );
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${client.name} → ${status.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final approved = _profile?.isApproved == true;
    return DefaultTabController(
      key: ValueKey(approved ? 'approved' : 'pending'),
      length: approved ? 3 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reseller'),
          actions: [
            IconButton(
              tooltip: 'Refresh (after Admin approval)',
              onPressed: _load,
              icon: const Icon(Icons.refresh),
            ),
            TextButton(
              onPressed: widget.onLogout,
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
          bottom: TabBar(
            tabs: approved
                ? const [
                    Tab(text: 'Dashboard'),
                    Tab(text: 'Clients'),
                    Tab(text: 'Sales'),
                  ]
                : const [Tab(text: 'Application')],
          ),
        ),
        floatingActionButton: approved
            ? FloatingActionButton.extended(
                onPressed: _addClient,
                icon: const Icon(Icons.person_add),
                label: const Text('Add client'),
              )
            : null,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    children: [
                      DemoBanner(
                        message: approved
                            ? 'Share your code at Customer checkout. Update client statuses so you can follow up.'
                            : 'Apply → wait for Ops Admin approve + code → then manage clients & sales.',
                      ),
                      Expanded(
                        child: TabBarView(
                          children: approved
                              ? [
                                  _dashboard(),
                                  _clientsTab(),
                                  _salesTab(),
                                ]
                              : [_pendingView()],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _pendingView() {
    final p = _profile!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.hourglass_top, size: 48),
        const SizedBox(height: 12),
        Text(
          'Application pending',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text('Hi ${widget.user.name.split(' ').first},'),
        Text(p.name),
        Text(p.email),
        if (p.academyName != null) Text('Academy: ${p.academyName}'),
        const SizedBox(height: 16),
        const Text(
          'Ops Admin must approve your reseller application and issue a '
          'Centre code (VNA-C-*) or Beneficiary code (VNA-B-*).\n\n'
          'Until then you cannot share a referral code, manage clients, '
          'or earn commission.\n\n'
          'Demo tip: logout → Sign in as Ops Admin → Resellers tab → '
          'Approve → pick Centre or Beneficiary → then come back here and tap Refresh.',
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Check approval status'),
        ),
        TextButton(
          onPressed: _showStatement,
          child: const Text('View application summary'),
        ),
      ],
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
          subtitle: Text('${p.code}  ·  ${p.codeType.label}'),
          trailing: IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: p.code));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${p.code} copied')),
              );
            },
          ),
        ),
        Text(
          p.codeType == ResellerCodeType.centre
              ? 'Centre code — for academies / centres (VNA-C-*)'
              : 'Beneficiary code — for independent / beneficiary resellers (VNA-B-*)',
          style: const TextStyle(fontSize: 12),
        ),
        ListTile(
          title: const Text('Total earned'),
          subtitle: Text('R${p.totalEarned.toStringAsFixed(2)}'),
        ),
        ListTile(
          title: const Text('Balance (payable by Digititan)'),
          subtitle: Text('R${p.balance.toStringAsFixed(2)}'),
        ),
        ListTile(
          title: const Text('Commission rate'),
          subtitle: Text('${p.commissionRate}%'),
        ),
        const Text(
          'Money flow (locked): Digititan pays resellers.\n'
          'Withdrawals: end of month, with approval.\n'
          'Bank auto-debit: later (not V1).',
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _showStatement,
          child: const Text('View monthly statement'),
        ),
        OutlinedButton(
          onPressed: _withdraw,
          child: const Text('Request month-end withdrawal'),
        ),
      ],
    );
  }

  Widget _clientsTab() {
    if (_clients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No clients yet.\nAdd people you are selling to, then update '
                'status: pending → confirmed → bought / didNotBuy.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _addClient,
                icon: const Icon(Icons.person_add),
                label: const Text('Add client'),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
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
            trailing: const Icon(Icons.edit),
            onTap: () => _updateClientStatus(c),
          ),
        );
      },
    );
  }

  Widget _salesTab() {
    if (_sales.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No sales yet.\nWhen a customer checks out with your referral code, '
            'the sale appears here automatically.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _sales.length,
      itemBuilder: (context, i) {
        final s = _sales[i];
        return Card(
          child: ListTile(
            title: Text(s.productName),
            subtitle: Text(
              '${s.clientName} · ${s.date.toIso8601String().substring(0, 10)}'
              '${s.referralCode == null ? '' : ' · ${s.referralCode}'}',
            ),
            trailing: Text('+R${s.commission.toStringAsFixed(2)}'),
          ),
        );
      },
    );
  }
}

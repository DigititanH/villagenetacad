import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/injection.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';
import '../customer/widgets/demo_role_switcher.dart';
import 'reseller_qr_card.dart';

class ResellerShell extends StatefulWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onLogout;
  final ValueChanged<User>? onDemoUserSwitched;
  final ValueChanged<AppHat>? onSwitchHat;

  const ResellerShell({
    super.key,
    required this.container,
    required this.user,
    required this.onLogout,
    this.onDemoUserSwitched,
    this.onSwitchHat,
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
  /// Demo-only: unlock withdrawal before real last day for walkthroughs.
  bool _demoSimulateMonthEnd = false;

  bool get _withdrawalOpen =>
      AppConfig.isLastDayOfMonth() || _demoSimulateMonthEnd;

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
    if (!_withdrawalOpen) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Withdrawals open only on the last day of the month '
            '(${AppConfig.lastDayLabel()}). Your money stays locked until then.',
          ),
        ),
      );
      return;
    }

    final available = _profile?.balance ?? 0;
    final minZar = AppConfig.minWithdrawalZar;
    final controller = TextEditingController(
      text: available >= minZar ? available.toStringAsFixed(0) : '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _MinWithdrawDialog(
        controller: controller,
        available: available,
        minZar: minZar,
      ),
    );
    if (ok != true) return;
    try {
      final amount = double.parse(controller.text.trim());
      if (amount < minZar) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: DigititanColors.danger,
            content: Text(
              'Minimum withdrawal is R${minZar.toStringAsFixed(0)}. Request blocked.',
            ),
          ),
        );
        return;
      }
      await widget.container.resellerRepository.requestWithdrawal(
        email: widget.user.email,
        amount: amount,
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal requested — Super Admin must approve'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: DigititanColors.danger,
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
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
            if (widget.onSwitchHat != null) ...[
              TextButton(
                onPressed: () {
                  widget.onSwitchHat!(AppHat.customer);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Switched to Customer app')),
                  );
                },
                child: const Text(
                  'Customer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (DemoHub.instance.isApprovedAmbassador(widget.user.email))
                TextButton(
                  onPressed: () {
                    widget.onSwitchHat!(AppHat.ambassador);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Switched to Ambassador view')),
                    );
                  },
                  child: const Text(
                    'Ambassador',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
            if (widget.onDemoUserSwitched != null)
              IconButton(
                tooltip: 'Demo role switch (decks)',
                icon: const Icon(Icons.swap_horiz),
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      child: DemoRoleSwitcher(
                        container: widget.container,
                        onSwitched: (User u) {
                          Navigator.pop(ctx);
                          widget.onDemoUserSwitched!(u);
                        },
                      ),
                    ),
                  );
                },
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
                            ? 'Your share only · withdraw on month-end'
                            : 'Awaiting Ops approval + referral code',
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
    final rejected = p.status == 'rejected';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        Icon(
          rejected ? Icons.block : Icons.hourglass_top,
          size: 44,
          color: DigititanColors.primary,
        ),
        const SizedBox(height: 14),
        Text(
          rejected ? 'Application rejected' : 'Application pending',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(p.email, style: Theme.of(context).textTheme.bodySmall),
        if (p.academyName != null) ...[
          const SizedBox(height: 4),
          Text('Academy: ${p.academyName}'),
        ],
        const SizedBox(height: 16),
        Text(
          rejected
              ? 'Ops Admin rejected this application. Contact Digititan support if you need to re-apply.'
              : 'Ops Admin will approve your application and issue a Beneficiary (VNA-B) or Centre (VNA-C) code. Until then clients and earnings stay locked.',
          style: const TextStyle(height: 1.4),
        ),
        const SizedBox(height: 20),
        if (!rejected)
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
    final shareLabel = p.codeType == ResellerCodeType.centre
        ? 'Centre (VNA-C) · ${p.commissionRate.toStringAsFixed(0)}%'
        : (p.academyName != null &&
                p.academyName!.toLowerCase().contains('independent'))
            ? 'Independent (VNA-B) · ${p.commissionRate.toStringAsFixed(0)}% · rest Digititan'
            : 'Beneficiary (VNA-B) · ${p.commissionRate.toStringAsFixed(0)}%'
                '${p.academyName != null && p.academyName!.trim().isNotEmpty ? ' · centre noted for 26%' : ''}';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text(
          'Hi ${widget.user.name.split(' ').first}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          p.academyName == null ? 'Status: ${p.status}' : '${p.status} · ${p.academyName}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DigititanColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DigititanColors.muted),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referral code',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(p.codeType.label, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: p.code));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${p.code} copied')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ResellerQrCard(
          code: p.code,
          resellerName: p.name,
          codeType: p.codeType,
          status: p.status,
          academyName: p.academyName,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DigititanColors.primaryDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shareLabel,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'R${p.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _withdrawalOpen
                    ? 'Withdrawal open today · min R${AppConfig.minWithdrawalZar.toStringAsFixed(0)}'
                    : 'Locked until ${AppConfig.lastDayLabel()}',
                style: TextStyle(
                  color: _withdrawalOpen
                      ? DigititanColors.teal
                      : Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (p.centreShareTotal > 0 || p.amountDueToDigititan > 0) ...[
                const SizedBox(height: 10),
                Text(
                  'Centre share (lifetime): R${p.centreShareTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Digititan share (lifetime): R${p.amountDueToDigititan.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Simulate month-end'),
          subtitle: const Text('Demo only'),
          value: _demoSimulateMonthEnd,
          onChanged: (v) => setState(() => _demoSimulateMonthEnd = v),
        ),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: _withdrawalOpen ? _withdraw : null,
          child: Text(
            _withdrawalOpen ? 'Withdraw' : 'Withdraw locked',
          ),
        ),
        TextButton(
          onPressed: _showStatement,
          child: const Text('Earnings statement'),
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
            'No sales yet.\nWhen a customer checks out with your code, '
            'your earnings (your share only) appear here.',
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
            trailing: Text(
              '+R${s.commission.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}

/// Blocks Request withdrawal until amount >= min (R100).
class _MinWithdrawDialog extends StatefulWidget {
  final TextEditingController controller;
  final double available;
  final double minZar;

  const _MinWithdrawDialog({
    required this.controller,
    required this.available,
    required this.minZar,
  });

  @override
  State<_MinWithdrawDialog> createState() => _MinWithdrawDialogState();
}

class _MinWithdrawDialogState extends State<_MinWithdrawDialog> {
  String? _error;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _validate(widget.controller.text);
  }

  void _validate(String raw) {
    final text = raw.trim();
    final amount = double.tryParse(text);
    setState(() {
      if (text.isEmpty || amount == null) {
        _error =
            'Enter an amount of at least R${widget.minZar.toStringAsFixed(0)}.';
        _canSubmit = false;
      } else if (amount < widget.minZar) {
        _error =
            'Minimum withdrawal is R${widget.minZar.toStringAsFixed(0)}. '
            'You entered R${amount.toStringAsFixed(0)} — request is blocked.';
        _canSubmit = false;
      } else if (amount > widget.available) {
        _error =
            'Not enough balance. You only have R${widget.available.toStringAsFixed(2)}.';
        _canSubmit = false;
      } else {
        _error = null;
        _canSubmit = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Withdraw (month-end)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Money due to you: R${widget.available.toStringAsFixed(2)}\n'
            'Minimum withdrawal: R${widget.minZar.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount (ZAR)',
              errorText: _error,
              errorMaxLines: 3,
              helperText: _canSubmit
                  ? 'Ready to request'
                  : 'Request withdrawal stays disabled under R${widget.minZar.toStringAsFixed(0)}',
              helperMaxLines: 2,
            ),
            onChanged: _validate,
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DigititanColors.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DigititanColors.danger, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: DigititanColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: DigititanColors.danger,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canSubmit ? () => Navigator.pop(context, true) : null,
          child: const Text('Request withdrawal'),
        ),
      ],
    );
  }
}

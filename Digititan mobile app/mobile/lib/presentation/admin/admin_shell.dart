import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';
import '../../shared/widgets/product_price_text.dart';

/// Ops Admin + Super Admin share this shell; tabs/actions gated by role.
class AdminShell extends StatefulWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onLogout;

  const AdminShell({
    super.key,
    required this.container,
    required this.user,
    required this.onLogout,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  AdminStats? _stats;
  List<ShopOrder> _orders = [];
  List<PendingResellerApplication> _pending = [];
  List<ResellerProfile> _resellerProfiles = [];
  List<AmbassadorApplication> _ambassadors = [];
  List<Product> _products = [];
  List<IssuedResellerCode> _codes = [];
  List<WithdrawalRequest> _withdrawals = [];
  List<String> _log = [];
  bool _loading = true;
  String? _error;

  bool get _isSuper => widget.user.role.isSuperAdmin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final admin = widget.container.adminRepository;
      final stats = await admin.getStats();
      final orders = await admin.getAllOrders();
      final pending = await admin.getPendingResellers();
      final resellerProfiles = await admin.getResellerProfiles();
      final ambassadors = await admin.getAmbassadorApplications();
      final products = await admin.getProducts();
      final codes = await admin.getIssuedCodes();
      final withdrawals = await admin.getPendingWithdrawals();
      final log = await admin.getActivityLog();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _orders = orders;
        _pending = pending;
        _resellerProfiles = resellerProfiles;
        _ambassadors = ambassadors.cast<AmbassadorApplication>();
        _products = products;
        _codes = codes.cast<IssuedResellerCode>();
        _withdrawals = withdrawals.cast<WithdrawalRequest>();
        _log = log;
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

  Future<void> _updateOrder(ShopOrder order) async {
    final status = await showDialog<OrderStatus>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Update ${order.id}'),
        children: OrderStatus.values
            .map(
              (s) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, s),
                child: Text(s.name),
              ),
            )
            .toList(),
      ),
    );
    if (status == null) return;
    await widget.container.adminRepository.updateOrderStatus(order.id, status);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${order.id} → ${status.name}')),
    );
  }

  Future<void> _approveReseller(PendingResellerApplication app) async {
    final linked = (app.academyName ?? '').trim();
    final type = await showDialog<ResellerCodeType>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Issue code for ${app.name}'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              linked.isEmpty
                  ? 'Who is selling?\n'
                      '• Individual person → Beneficiary (VNA-B-*) — earns 53%\n'
                      '• Centre / academy organisation → Centre (VNA-C-*) — earns 26%\n\n'
                      'If an individual is linked to a centre, still choose Beneficiary; '
                      'the linked centre gets the 26% slice from their sales.'
                  : 'Applicant listed centre: $linked\n\n'
                      'Who is selling?\n'
                      '• Individual person (e.g. Sipho) → Beneficiary (VNA-B-*) — earns 53%\n'
                      '  (linked centre still gets 26% from their sales)\n'
                      '• Centre / academy organisation → Centre (VNA-C-*) — earns 26%',
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ResellerCodeType.beneficiary),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Beneficiary — VNA-B-*'),
              subtitle: Text('Individual reseller · earns 53%'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ResellerCodeType.centre),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Centre — VNA-C-*'),
              subtitle: Text('Centre / academy organisation · earns 26%'),
            ),
          ),
        ],
      ),
    );
    if (type == null) return;
    final code = await widget.container.adminRepository.approveReseller(
      app.id,
      codeType: type,
    );
    await _load();
    if (!mounted) return;
    final tip = type == ResellerCodeType.beneficiary
        ? 'Individual code. Linked centre (if any) still gets 26% on their sales.'
        : 'Centre organisation code — centre earns 26%.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved ${app.name}. Code: $code. $tip')),
    );
  }

  Future<void> _rejectReseller(PendingResellerApplication app) async {
    await widget.container.adminRepository.rejectReseller(app.id);
    await _load();
  }

  Future<void> _approveAmbassador(AmbassadorApplication app) async {
    await widget.container.adminRepository.approveAmbassador(app.id);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${app.name} is now an official ambassador')),
    );
  }

  Future<void> _rejectAmbassador(AmbassadorApplication app) async {
    await widget.container.adminRepository.rejectAmbassador(app.id);
    await _load();
  }

  Future<void> _confirmDeactivate({
    required String title,
    required String body,
    required Future<void> Function() action,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (ok != true) return;
    await action();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deactivated — account locked until reactivated or Digititan unlocks'),
      ),
    );
  }

  Future<void> _editPrice(Product product) async {
    final controller = TextEditingController(text: product.price.toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Price: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'New price (ZAR)'),
            ),
            const SizedBox(height: 8),
            Text(
              product.showsSalePrice
                  ? 'Current: was ${moneyZar(product.compareAtPrice!)} → now ${moneyZar(product.price)}'
                  : 'Tip: lower the price while on promo to show ~~old~~ new on Store/Home.',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    await widget.container.adminRepository.updateProductPrice(
      product.id,
      double.parse(controller.text),
    );
    await _load();
  }

  /// Mark promo and capture was/now so Store shows strikethrough.
  Future<bool?> _markPromo(Product product) async {
    final wasCtrl = TextEditingController(
      text: (product.compareAtPrice ?? product.price).toStringAsFixed(0),
    );
    final nowCtrl = TextEditingController(text: product.price.toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Promo: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wasCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Was price (struck through)',
              ),
            ),
            TextField(
              controller: nowCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Promo / now price',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apply')),
        ],
      ),
    );
    if (ok != true) return false;
    final was = double.parse(wasCtrl.text);
    final now = double.parse(nowCtrl.text);
    if (now >= was) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promo price must be lower than was price')),
      );
      return false;
    }
    // Set price first (stores compare-at), then flag promo.
    await widget.container.adminRepository.updateProductPrice(product.id, was);
    await widget.container.adminRepository.updateProductPrice(product.id, now);
    await widget.container.adminRepository.setProductPromotion(product.id, true);
    return true;
  }

  Future<void> _addProduct() async {
    final name = TextEditingController();
    final category = TextEditingController(text: 'Hardware');
    final summary = TextEditingController();
    final price = TextEditingController(text: '299');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add sample product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: summary, decoration: const InputDecoration(labelText: 'Summary')),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (ZAR)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    await widget.container.adminRepository.addProduct(
      name: name.text.trim(),
      category: category.text.trim(),
      summary: summary.text.trim(),
      price: double.parse(price.text),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Tab>[
      const Tab(text: 'Dashboard'),
      const Tab(text: 'Orders'),
      const Tab(text: 'Resellers'),
      const Tab(text: 'Ambassadors'),
      const Tab(text: 'Codes'),
      const Tab(text: 'Products'),
      if (_isSuper) const Tab(text: 'Payouts'),
      if (_isSuper) const Tab(text: 'Activity'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.role.label),
          actions: [
            TextButton(
              onPressed: widget.onLogout,
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: DigititanColors.teal,
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addProduct,
          icon: const Icon(Icons.add),
          label: const Text('Add product'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    children: [
                      DemoBanner(
                        message: _isSuper
                            ? 'Super Admin · oversight + payouts'
                            : 'Ops Admin · orders, resellers, ambassadors, codes',
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _dashboard(),
                            _ordersTab(),
                            _resellersTab(),
                            _ambassadorsTab(),
                            _codesTab(),
                            _productsTab(),
                            if (_isSuper) _payoutsTab(),
                            if (_isSuper) _activityTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _dashboard() {
    final s = _stats!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        Text(
          widget.user.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(widget.user.email, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [
            MetricTile(
              label: 'Orders',
              value: '${s.totalOrders}',
              icon: Icons.receipt_long_outlined,
            ),
            MetricTile(
              label: 'Revenue',
              value: 'R${s.totalRevenue.toStringAsFixed(0)}',
              icon: Icons.payments_outlined,
            ),
            MetricTile(
              label: 'Pending orders',
              value: '${s.pendingOrders}',
              icon: Icons.hourglass_empty,
            ),
            MetricTile(
              label: 'Pending resellers',
              value: '${s.pendingResellers}',
              icon: Icons.person_add_alt_1_outlined,
            ),
            MetricTile(
              label: 'Pending ambassadors',
              value: '${s.pendingAmbassadors}',
              icon: Icons.campaign_outlined,
            ),
            MetricTile(
              label: 'Products',
              value: '${s.products}',
              icon: Icons.inventory_2_outlined,
            ),
            MetricTile(
              label: 'Withdrawals',
              value: '${s.pendingWithdrawals}',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
        ),
        const SizedBox(height: 14),
        QuietNotice(
          message:
              'Ops: Resellers tab = approve + deactivate. '
              'Ambassadors tab = approve applications + list/deactivate. '
              'Deactivated users cannot log in until reactivated.',
        ),
      ],
    );
  }

  Widget _ordersTab() {
    if (_orders.isEmpty) {
      return const Center(child: Text('No orders yet — place one as Customer'));
    }
    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, i) {
        final o = _orders[i];
        return ListTile(
          title: Text(o.id),
          subtitle: Text(
            '${o.buyerEmail} · ${o.status.name} · R${o.total.toStringAsFixed(0)}'
            '${o.referralCode == null ? '' : ' · code ${o.referralCode}'}',
          ),
          trailing: const Icon(Icons.edit),
          onTap: () => _updateOrder(o),
        );
      },
    );
  }

  Widget _resellersTab() {
    final profiles = [..._resellerProfiles]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      children: [
        Text('Pending applications', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Approve → issues VNA-B-* / VNA-C-* code. Long-press to reject.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (_pending.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No pending reseller applications'),
          )
        else
          ..._pending.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  isThreeLine: true,
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.email}\n${p.academyName ?? 'Independent / programme support'}',
                  ),
                  trailing: TextButton(
                    onPressed: () => _approveReseller(p),
                    child: const Text('Approve'),
                  ),
                  onLongPress: () => _rejectReseller(p),
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
        Text('All resellers', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Deactivate locks login and disables their referral code.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (profiles.isEmpty)
          const Text('No reseller profiles yet')
        else
          ...profiles.map((p) {
            final deactivated = p.isDeactivated;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  isThreeLine: true,
                  leading: Icon(
                    deactivated ? Icons.lock_outline : Icons.storefront_outlined,
                    color: deactivated ? Colors.redAccent : null,
                  ),
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.email}\n'
                    '${p.code} · ${p.codeType.label} · ${p.status}'
                    '${p.academyName == null ? '' : ' · ${p.academyName}'}'
                    '\nEarned R${p.totalEarned.toStringAsFixed(0)} · balance R${p.balance.toStringAsFixed(0)}',
                  ),
                  trailing: deactivated
                      ? TextButton(
                          onPressed: () async {
                            await widget.container.adminRepository
                                .reactivateReseller(p.email);
                            await _load();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${p.name} reactivated')),
                            );
                          },
                          child: const Text('Unlock'),
                        )
                      : TextButton(
                          onPressed: p.status == 'approved'
                              ? () => _confirmDeactivate(
                                    title: 'Deactivate ${p.name}?',
                                    body:
                                        'They will be locked out of login and their code '
                                        '(${p.code}) will stop working until you unlock them '
                                        'or Digititan reactivates the account.',
                                    action: () => widget.container.adminRepository
                                        .deactivateReseller(p.email),
                                  )
                              : null,
                          child: const Text('Deactivate'),
                        ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _ambassadorsTab() {
    final pending =
        _ambassadors.where((a) => a.status == 'under_review').toList();
    final all = [..._ambassadors]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      children: [
        Text('Pending applications', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'You apply → under review → Ops Admin approves → official ambassador.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (pending.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No ambassador applications under review'),
          )
        else
          ...pending.map((a) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  isThreeLine: true,
                  title: Text(a.name),
                  subtitle: Text(
                    '${a.email} · ${a.phone}\n${a.motivation}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => _rejectAmbassador(a),
                        child: const Text('Reject'),
                      ),
                      FilledButton(
                        onPressed: () => _approveAmbassador(a),
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
        Text('All ambassadors', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Full list with details. Deactivate locks their login until unlocked.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (all.isEmpty)
          const Text('No ambassador applications yet')
        else
          ...all.map((a) {
            final deactivated = a.isDeactivated;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  isThreeLine: true,
                  leading: Icon(
                    deactivated
                        ? Icons.lock_outline
                        : a.isApproved
                            ? Icons.verified_outlined
                            : Icons.pending_outlined,
                    color: deactivated ? Colors.redAccent : null,
                  ),
                  title: Text(a.name),
                  subtitle: Text(
                    '${a.email}\n'
                    '${a.phone} · ${a.status}\n'
                    '${a.motivation}',
                  ),
                  trailing: deactivated
                      ? TextButton(
                          onPressed: () async {
                            await widget.container.adminRepository
                                .reactivateAmbassador(a.id);
                            await _load();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${a.name} reactivated')),
                            );
                          },
                          child: const Text('Unlock'),
                        )
                      : a.isApproved
                          ? TextButton(
                              onPressed: () => _confirmDeactivate(
                                title: 'Deactivate ${a.name}?',
                                body:
                                    'They will be locked out of login until you unlock '
                                    'them or they contact Digititan.',
                                action: () => widget.container.adminRepository
                                    .deactivateAmbassador(a.id),
                              ),
                              child: const Text('Deactivate'),
                            )
                          : null,
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _codesTab() {
    if (_codes.isEmpty) {
      return const Center(child: Text('No codes issued yet'));
    }
    final sorted = [..._codes]..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final c = sorted[i];
        return ListTile(
          leading: Icon(
            c.type == ResellerCodeType.centre ? Icons.apartment : Icons.person,
          ),
          title: Text(c.code),
          subtitle: Text(
            '${c.type.label} · ${c.resellerName} <${c.resellerEmail}>\n'
            '${c.academyName ?? 'Independent'} · ${c.active ? 'active' : 'inactive'}',
          ),
          isThreeLine: true,
        );
      },
    );
  }

  Widget _productsTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 88),
      itemCount: _products.length,
      itemBuilder: (context, i) {
        final p = _products[i];
        return ListTile(
          title: Text(p.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${p.category} · ${p.inStock ? 'In stock' : 'Out of stock'}'
                '${p.onPromotion ? ' · PROMO' : ''}'
                '${p.isBestSeller ? ' · Best seller' : ''}',
              ),
              ProductPriceText(product: p, compact: true),
            ],
          ),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: p.onPromotion ? 'Remove promo' : 'Mark promo/special',
                icon: Icon(
                  p.onPromotion ? Icons.local_offer : Icons.local_offer_outlined,
                ),
                onPressed: () async {
                  if (p.onPromotion) {
                    await widget.container.adminRepository.setProductPromotion(
                      p.id,
                      false,
                    );
                  } else {
                    final ok = await _markPromo(p);
                    if (ok != true) return;
                  }
                  await _load();
                },
              ),
              IconButton(
                tooltip: 'Edit price',
                icon: const Icon(Icons.price_change_outlined),
                onPressed: () => _editPrice(p),
              ),
            ],
          ),
          onLongPress: () async {
            await widget.container.adminRepository.setProductStock(p.id, !p.inStock);
            await _load();
          },
        );
      },
    );
  }

  Widget _payoutsTab() {
    if (_withdrawals.isEmpty) {
      return const Center(child: Text('No pending withdrawals'));
    }
    return ListView.builder(
      itemCount: _withdrawals.length,
      itemBuilder: (context, i) {
        final w = _withdrawals[i];
        return Card(
          child: ListTile(
            title: Text('${w.resellerName} · R${w.amount.toStringAsFixed(0)}'),
            subtitle: Text(w.resellerEmail),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () async {
                    await widget.container.adminRepository.approveWithdrawal(w.id);
                    await _load();
                  },
                  child: const Text('Approve'),
                ),
                TextButton(
                  onPressed: () async {
                    await widget.container.adminRepository.rejectWithdrawal(w.id);
                    await _load();
                  },
                  child: const Text('Reject'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _activityTab() {
    if (_log.isEmpty) return const Center(child: Text('No activity yet'));
    return ListView.builder(
      itemCount: _log.length,
      itemBuilder: (context, i) => ListTile(
        dense: true,
        title: Text(_log[i], style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

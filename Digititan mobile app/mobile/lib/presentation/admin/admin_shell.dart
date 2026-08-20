import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/widgets/demo_banner.dart';

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
      final products = await admin.getProducts();
      final codes = await admin.getIssuedCodes();
      final withdrawals = await admin.getPendingWithdrawals();
      final log = await admin.getActivityLog();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _orders = orders;
        _pending = pending;
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
    final type = await showDialog<ResellerCodeType>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Issue code for ${app.name}'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ResellerCodeType.centre),
            child: const Text('Centre code (VNA-C-*)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ResellerCodeType.beneficiary),
            child: const Text('Beneficiary code (VNA-B-*)'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved ${app.name}. Code: $code (${type.label})')),
    );
  }

  Future<void> _rejectReseller(PendingResellerApplication app) async {
    await widget.container.adminRepository.rejectReseller(app.id);
    await _load();
  }

  Future<void> _editPrice(Product product) async {
    final controller = TextEditingController(text: product.price.toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Price: ${product.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'ZAR'),
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
          bottom: TabBar(isScrollable: true, tabs: tabs),
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
                            ? 'Super Admin: oversight + payout approvals. Ops Admin can add/update day-to-day without you.'
                            : 'Ops Admin: update orders, products, approve resellers (issue VNA-C / VNA-B codes) — no Super Admin needed.',
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _dashboard(),
                            _ordersTab(),
                            _resellersTab(),
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
      padding: const EdgeInsets.all(16),
      children: [
        Text('${widget.user.name} · ${widget.user.email}'),
        const SizedBox(height: 12),
        _stat('Orders (live demo)', '${s.totalOrders}'),
        _stat('Revenue (live demo)', 'R${s.totalRevenue.toStringAsFixed(0)}'),
        _stat('Pending orders', '${s.pendingOrders}'),
        _stat('Pending resellers', '${s.pendingResellers}'),
        _stat('Products', '${s.products}'),
        _stat('Pending withdrawals', '${s.pendingWithdrawals}'),
        _stat('Open leads', '${s.openLeads}'),
        const SizedBox(height: 12),
        const Text(
          'Try: Customer checkout with code VNA-B-LERATO → Reseller Sales updates → Admin Orders shows the order.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) => Card(
        child: ListTile(title: Text(label), trailing: Text(value)),
      );

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
    if (_pending.isEmpty) {
      return const Center(child: Text('No pending reseller applications'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      itemCount: _pending.length,
      itemBuilder: (context, i) {
        final p = _pending[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(p.email),
                Text(p.academyName ?? 'Independent / programme support'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _approveReseller(p),
                      child: const Text('Approve + issue code'),
                    ),
                    TextButton(
                      onPressed: () => _rejectReseller(p),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      itemCount: _products.length,
      itemBuilder: (context, i) {
        final p = _products[i];
        return ListTile(
          title: Text(p.name),
          subtitle: Text(
            '${p.category} · R${p.price.toStringAsFixed(0)} · '
            '${p.inStock ? 'In stock' : 'Out of stock'}',
          ),
          trailing: const Icon(Icons.price_change_outlined),
          onTap: () => _editPrice(p),
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

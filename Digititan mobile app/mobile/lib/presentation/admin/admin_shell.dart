import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../shared/widgets/demo_banner.dart';

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
  bool _loading = true;
  String? _error;

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
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _orders = orders;
        _pending = pending;
        _products = products;
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
  }

  Future<void> _approve(PendingResellerApplication app) async {
    final code = await widget.container.adminRepository.approveReseller(app.id);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved ${app.name}. Code: $code')),
    );
  }

  Future<void> _editPrice(Product product) async {
    final controller = TextEditingController(text: product.price.toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update price: ${product.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New price (ZAR)'),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          actions: [
            TextButton(
              onPressed: widget.onLogout,
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Orders'),
              Tab(text: 'Resellers'),
              Tab(text: 'Products'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    children: [
                      const DemoBanner(
                        message:
                            'Say aloud: second-level admin can update ops without developers.',
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _dashboard(),
                            _ordersTab(),
                            _resellersTab(),
                            _productsTab(),
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
        Text('Signed in as ${widget.user.name}'),
        const SizedBox(height: 12),
        _stat('Total users', '${s.totalUsers}'),
        _stat('Total revenue', 'R${s.totalRevenue.toStringAsFixed(0)}'),
        _stat('Total orders', '${s.totalOrders}'),
        _stat('Pending orders', '${s.pendingOrders}'),
        _stat('Pending resellers', '${s.pendingResellers}'),
        _stat('Products', '${s.products}'),
        const SizedBox(height: 12),
        const Text(
          'Second-level admin can update content/orders without developers (meeting requirement).',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) => Card(
        child: ListTile(title: Text(label), trailing: Text(value)),
      );

  Widget _ordersTab() {
    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, i) {
        final o = _orders[i];
        return ListTile(
          title: Text(o.id),
          subtitle: Text('${o.buyerEmail} · ${o.status.name} · R${o.total.toStringAsFixed(0)}'),
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
      itemCount: _pending.length,
      itemBuilder: (context, i) {
        final p = _pending[i];
        return Card(
          child: ListTile(
            title: Text(p.name),
            subtitle: Text(
              '${p.email}\n'
              '${p.academyName ?? 'Independent / programme support'} · '
              '${p.appliedAt.toIso8601String().substring(0, 10)}',
            ),
            isThreeLine: true,
            trailing: ElevatedButton(
              onPressed: () => _approve(p),
              child: const Text('Approve'),
            ),
          ),
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
          subtitle: Text('${p.category} · R${p.price.toStringAsFixed(0)}'),
          trailing: const Icon(Icons.price_change_outlined),
          onTap: () => _editPrice(p),
        );
      },
    );
  }
}

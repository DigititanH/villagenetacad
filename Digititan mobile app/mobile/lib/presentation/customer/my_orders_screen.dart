import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/shop_order.dart';
import '../../domain/entities/user.dart';
import '../../shared/result/result.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final AppContainer container;
  final User user;

  const MyOrdersScreen({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _loading = true;
  String? _error;
  List<ShopOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.container.getMyOrders(widget.user.email);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          _orders = data;
        case Failure(:final message):
          _error = message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _orders.isEmpty
                  ? const Center(child: Text('No orders yet'))
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, i) {
                        final o = _orders[i];
                        return ListTile(
                          title: Text(o.id),
                          subtitle: Text(
                            '${o.status.name} · R${o.total.toStringAsFixed(0)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(
                                  container: widget.container,
                                  orderId: o.id,
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

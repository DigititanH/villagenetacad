import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/store_repository.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final AppContainer container;
  final User user;

  const CartScreen({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartLine> get _lines => widget.container.storeRepository.getCart();

  @override
  Widget build(BuildContext context) {
    final total = widget.container.storeRepository.cartTotal();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: _lines.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _lines.length,
                    itemBuilder: (context, i) {
                      final line = _lines[i];
                      return ListTile(
                        title: Text(line.product.name),
                        subtitle: Text(
                          'R${line.product.price.toStringAsFixed(0)} × ${line.quantity}'
                          ' = R${line.lineTotal.toStringAsFixed(0)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                widget.container.storeRepository.updateQuantity(
                                  line.product.id,
                                  line.quantity - 1,
                                );
                                setState(() {});
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            Text('${line.quantity}'),
                            IconButton(
                              onPressed: () {
                                widget.container.storeRepository.updateQuantity(
                                  line.product.id,
                                  line.quantity + 1,
                                );
                                setState(() {});
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Total: R${total.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                container: widget.container,
                                user: widget.user,
                              ),
                            ),
                          );
                        },
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

enum OrderStatus {
  placed,
  paid,
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get lineTotal => unitPrice * quantity;
}

class ShopOrder {
  final String id;
  final String buyerEmail;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final List<String> trackingTimeline;

  const ShopOrder({
    required this.id,
    required this.buyerEmail,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.trackingTimeline,
  });

  double get total => items.fold(0, (sum, i) => sum + i.lineTotal);
}

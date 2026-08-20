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
  final String? referralCode;

  const ShopOrder({
    required this.id,
    required this.buyerEmail,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.trackingTimeline,
    this.referralCode,
  });

  double get total => items.fold(0, (sum, i) => sum + i.lineTotal);

  ShopOrder copyWith({
    OrderStatus? status,
    List<String>? trackingTimeline,
    String? referralCode,
  }) {
    return ShopOrder(
      id: id,
      buyerEmail: buyerEmail,
      items: items,
      status: status ?? this.status,
      createdAt: createdAt,
      trackingTimeline: trackingTimeline ?? this.trackingTimeline,
      referralCode: referralCode ?? this.referralCode,
    );
  }
}

enum OrderStatus {
  placed,
  paid,
  processing,
  shipped,
  delivered,
  cancelled,
  returnRequested,
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
  /// Set when status becomes delivered — drives 7-day return window.
  final DateTime? deliveredAt;
  final bool returnRequested;
  final bool reviewed;
  final String? reviewText;
  final int? reviewStars;

  const ShopOrder({
    required this.id,
    required this.buyerEmail,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.trackingTimeline,
    this.referralCode,
    this.deliveredAt,
    this.returnRequested = false,
    this.reviewed = false,
    this.reviewText,
    this.reviewStars,
  });

  double get total => items.fold(0, (sum, i) => sum + i.lineTotal);

  bool get canRequestReturn {
    if (returnRequested) return false;
    if (status != OrderStatus.delivered || deliveredAt == null) return false;
    final deadline = deliveredAt!.add(const Duration(days: 7));
    return DateTime.now().isBefore(deadline) ||
        DateTime.now().isAtSameMomentAs(deadline);
  }

  int get returnDaysLeft {
    if (deliveredAt == null) return 0;
    final deadline = deliveredAt!.add(const Duration(days: 7));
    final left = deadline.difference(DateTime.now()).inDays;
    return left < 0 ? 0 : left;
  }

  bool get canReview => status == OrderStatus.delivered && !reviewed;

  ShopOrder copyWith({
    OrderStatus? status,
    List<String>? trackingTimeline,
    String? referralCode,
    DateTime? deliveredAt,
    bool? returnRequested,
    bool? reviewed,
    String? reviewText,
    int? reviewStars,
  }) {
    return ShopOrder(
      id: id,
      buyerEmail: buyerEmail,
      items: items,
      status: status ?? this.status,
      createdAt: createdAt,
      trackingTimeline: trackingTimeline ?? this.trackingTimeline,
      referralCode: referralCode ?? this.referralCode,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      returnRequested: returnRequested ?? this.returnRequested,
      reviewed: reviewed ?? this.reviewed,
      reviewText: reviewText ?? this.reviewText,
      reviewStars: reviewStars ?? this.reviewStars,
    );
  }
}

enum ResellerClientStatus {
  pending,
  confirmed,
  bought,
  didNotBuy,
}

class ResellerClient {
  final String id;
  final String name;
  final String email;
  final ResellerClientStatus status;
  final String? productInterest;
  final DateTime updatedAt;

  const ResellerClient({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.productInterest,
    required this.updatedAt,
  });
}

class ResellerSale {
  final String id;
  final String clientName;
  final String productName;
  final double amount;
  final double commission;
  final DateTime date;

  const ResellerSale({
    required this.id,
    required this.clientName,
    required this.productName,
    required this.amount,
    required this.commission,
    required this.date,
  });
}

class ResellerProfile {
  final String code;
  final String status; // pending | approved
  final double totalEarned;
  final double balance;
  final double amountDueToDigititan;
  final double commissionRate;
  final String? academyName;

  const ResellerProfile({
    required this.code,
    required this.status,
    required this.totalEarned,
    required this.balance,
    required this.amountDueToDigititan,
    required this.commissionRate,
    this.academyName,
  });
}

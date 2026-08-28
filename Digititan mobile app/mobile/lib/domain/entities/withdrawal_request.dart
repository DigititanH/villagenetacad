class WithdrawalRequest {
  final String id;
  final String resellerEmail;
  final String resellerName;
  final double amount;
  final DateTime createdAt;
  String status;

  WithdrawalRequest({
    required this.id,
    required this.resellerEmail,
    required this.resellerName,
    required this.amount,
    required this.createdAt,
    this.status = 'pending',
  });
}

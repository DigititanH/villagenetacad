enum ResellerClientStatus {
  pending,
  confirmed,
  bought,
  didNotBuy,
}

/// Locked decision: different codes for centres vs beneficiaries.
enum ResellerCodeType {
  centre,
  beneficiary,
}

extension ResellerCodeTypeX on ResellerCodeType {
  String get label {
    switch (this) {
      case ResellerCodeType.centre:
        return 'Centre';
      case ResellerCodeType.beneficiary:
        return 'Beneficiary';
    }
  }

  String get prefix {
    switch (this) {
      case ResellerCodeType.centre:
        return 'VNA-C';
      case ResellerCodeType.beneficiary:
        return 'VNA-B';
    }
  }
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
  final String? referralCode;

  const ResellerSale({
    required this.id,
    required this.clientName,
    required this.productName,
    required this.amount,
    required this.commission,
    required this.date,
    this.referralCode,
  });
}

class ResellerProfile {
  final String email;
  final String name;
  final String code;
  final ResellerCodeType codeType;
  final String status; // pending | approved
  final double totalEarned;
  final double balance;
  final double amountDueToDigititan;
  final double commissionRate;
  final String? academyName;

  const ResellerProfile({
    required this.email,
    required this.name,
    required this.code,
    required this.codeType,
    required this.status,
    required this.totalEarned,
    required this.balance,
    required this.amountDueToDigititan,
    required this.commissionRate,
    this.academyName,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';

  ResellerProfile copyWith({
    double? totalEarned,
    double? balance,
    String? status,
    String? code,
    ResellerCodeType? codeType,
    String? academyName,
    double? amountDueToDigititan,
    double? commissionRate,
  }) {
    return ResellerProfile(
      email: email,
      name: name,
      code: code ?? this.code,
      codeType: codeType ?? this.codeType,
      status: status ?? this.status,
      totalEarned: totalEarned ?? this.totalEarned,
      balance: balance ?? this.balance,
      amountDueToDigititan: amountDueToDigititan ?? this.amountDueToDigititan,
      commissionRate: commissionRate ?? this.commissionRate,
      academyName: academyName ?? this.academyName,
    );
  }
}

class IssuedResellerCode {
  final String code;
  final ResellerCodeType type;
  final String resellerEmail;
  final String resellerName;
  final String? academyName;
  final DateTime issuedAt;
  bool active;

  IssuedResellerCode({
    required this.code,
    required this.type,
    required this.resellerEmail,
    required this.resellerName,
    this.academyName,
    required this.issuedAt,
    this.active = true,
  });
}

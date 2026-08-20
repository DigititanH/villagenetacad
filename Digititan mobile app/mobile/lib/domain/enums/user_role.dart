/// Domain enums = business vocabulary.
/// No Flutter imports. No UI. No Firebase.
enum UserRole {
  customer,
  reseller,
  /// Day-to-day ops: products, orders, reseller approve, leads — no Super Admin needed.
  opsAdmin,
  /// Oversight: everything Ops can do + withdrawals, org approvals, activity log.
  superAdmin,
}

extension UserRoleX on UserRole {
  bool get isAdmin => this == UserRole.opsAdmin || this == UserRole.superAdmin;
  bool get isSuperAdmin => this == UserRole.superAdmin;

  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.reseller:
        return 'Reseller';
      case UserRole.opsAdmin:
        return 'Ops Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }
}

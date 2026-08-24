/// Domain enums = business vocabulary.
/// No Flutter imports. No UI. No Firebase.
enum UserRole {
  customer,
  reseller,
  /// Programme promoter (not a seller). Hat switched from Profile after Ops approval.
  ambassador,
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
      case UserRole.ambassador:
        return 'Ambassador';
      case UserRole.opsAdmin:
        return 'Ops Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }
}

/// Which “hat” the signed-in person is wearing right now (same account).
enum AppHat {
  customer,
  reseller,
  ambassador,
}

extension AppHatX on AppHat {
  String get label {
    switch (this) {
      case AppHat.customer:
        return 'Customer';
      case AppHat.reseller:
        return 'Reseller';
      case AppHat.ambassador:
        return 'Ambassador';
    }
  }
}


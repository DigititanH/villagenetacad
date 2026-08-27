import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../infrastructure/dummy/demo_hub.dart';

/// Session helpers for approved Customer ↔ Reseller view switching (Profile).
class ApprovedRoleSwitch {
  ApprovedRoleSwitch._();

  static bool isApprovedReseller(String email) {
    final p = DemoHub.instance.resellerProfiles[email.trim().toLowerCase()];
    return p?.isApproved == true;
  }

  static bool isPendingReseller(String email) {
    final p = DemoHub.instance.resellerProfiles[email.trim().toLowerCase()];
    return p?.isPending == true;
  }

  static bool isApprovedAmbassador(String email) {
    final key = email.trim().toLowerCase();
    for (final a in DemoHub.instance.ambassadorApplications) {
      if (a.email.toLowerCase() == key && a.isApproved) return true;
    }
    return false;
  }

  static User asRole(User user, UserRole role) {
    return User(
      id: user.id,
      name: user.name,
      email: user.email,
      role: role,
      emailVerified: user.emailVerified,
    );
  }
}

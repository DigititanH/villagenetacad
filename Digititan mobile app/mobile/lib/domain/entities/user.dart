import '../enums/user_role.dart';

/// Entity = a real business object in Digititan.
/// Encapsulates identity + role. Immutable for safety.
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool emailVerified;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.emailVerified = false,
  });
}

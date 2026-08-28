import '../entities/user.dart';
import '../enums/user_role.dart';

/// Abstraction (OOP) + Dependency Inversion (SOLID D).
/// Application/UI depend on THIS contract, not Firebase/Gmail.
///
/// Polymorphism: DummyAuthRepository and FirebaseAuthRepository
/// will both implement this later.
abstract class AuthRepository {
  Future<User?> getCurrentUser();

  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates an account and returns it.
  ///
  /// [resellerKind]: `independent` | `affiliated` | `centre` (live reseller only).
  /// [academyName]: required for affiliated/centre; ignored/blank for independent.
  Future<User> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? academyName,
    String? resellerKind,
  });

  Future<User> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<void> signOut();
}

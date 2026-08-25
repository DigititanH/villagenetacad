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
  /// [academyName] is required by the live API when [role] is reseller.
  Future<User> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? academyName,
  });

  Future<User> verifyEmailOtp({
    required String email,
    required String otp,
  });

  /// Google path — implementation later.
  Future<User> signInWithGoogle();

  Future<void> signOut();
}

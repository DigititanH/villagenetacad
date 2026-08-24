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

  /// Creates an unverified account and returns it.
  /// OTP sending is orchestrated by a use-case, not hidden forever.
  Future<User> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<User> verifyEmailOtp({
    required String email,
    required String otp,
  });

  /// Google path — implementation later.
  Future<User> signInWithGoogle();

  Future<void> signOut();
}

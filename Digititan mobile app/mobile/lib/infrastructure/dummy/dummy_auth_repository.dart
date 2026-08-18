import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

/// Prototype implementation of AuthRepository.
/// In-memory only — no real network. Good for screens + demos.
///
/// Polymorphism: same interface as future FirebaseAuthRepository.
class DummyAuthRepository implements AuthRepository {
  User? _current;

  /// Demo accounts for stakeholder walkthroughs.
  final Map<String, _StoredAccount> _accounts = {
    'customer@demo.com': _StoredAccount(
      password: 'demo123',
      user: const User(
        id: 'u-customer',
        name: 'Demo Customer',
        email: 'customer@demo.com',
        role: UserRole.customer,
        emailVerified: true,
      ),
    ),
    'reseller@demo.com': _StoredAccount(
      password: 'demo123',
      user: const User(
        id: 'u-reseller',
        name: 'Demo Reseller',
        email: 'reseller@demo.com',
        role: UserRole.reseller,
        emailVerified: true,
      ),
    ),
    'admin@demo.com': _StoredAccount(
      password: 'demo123',
      user: const User(
        id: 'u-admin',
        name: 'Demo Admin',
        email: 'admin@demo.com',
        role: UserRole.admin,
        emailVerified: true,
      ),
    ),
  };

  /// email -> latest OTP (prototype only)
  final Map<String, String> _otps = {};

  @override
  Future<User?> getCurrentUser() async => _current;

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    final account = _accounts[key];
    if (account == null || account.password != password) {
      throw Exception('Invalid email or password');
    }
    if (!account.user.emailVerified) {
      throw Exception('Email not verified. Enter the OTP sent to your inbox.');
    }
    _current = account.user;
    return account.user;
  }

  @override
  Future<User> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw Exception('An account with this email already exists');
    }

    final user = User(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: key,
      role: role,
      emailVerified: false,
    );

    _accounts[key] = _StoredAccount(password: password, user: user);

    // Fixed OTP for prototype predictability. Real system = random + expiry.
    _otps[key] = '123456';
    return user;
  }

  @override
  Future<User> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final key = email.trim().toLowerCase();
    final expected = _otps[key];
    final account = _accounts[key];
    if (account == null) {
      throw Exception('No pending registration for this email');
    }
    if (expected == null || expected != otp.trim()) {
      throw Exception('Invalid OTP');
    }

    final verified = User(
      id: account.user.id,
      name: account.user.name,
      email: account.user.email,
      role: account.user.role,
      emailVerified: true,
    );
    _accounts[key] = _StoredAccount(password: account.password, user: verified);
    _otps.remove(key);
    _current = verified;
    return verified;
  }

  @override
  Future<User> signInWithGoogle() async {
    // Placeholder until Firebase Google Sign-In is wired.
    // For now: log in as verified customer demo user.
    final account = _accounts['customer@demo.com']!;
    _current = account.user;
    return account.user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
  }

  /// Prototype helper so Register use-case can read the OTP it "sent".
  String? debugOtpFor(String email) => _otps[email.trim().toLowerCase()];
}

class _StoredAccount {
  final String password;
  final User user;
  _StoredAccount({required this.password, required this.user});
}

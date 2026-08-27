import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import 'demo_hub.dart';

class DummyAuthRepository implements AuthRepository {
  User? _current;

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
    'lerato.ambassador@example.com': _StoredAccount(
      password: 'demo123',
      user: const User(
        id: 'u-ambassador',
        name: 'Lerato Dube',
        email: 'lerato.ambassador@example.com',
        role: UserRole.customer,
        emailVerified: true,
      ),
    ),
    'ops@demo.com': _StoredAccount(
      password: 'demo123',
      user: const User(
        id: 'u-ops',
        name: 'Demo Ops Admin',
        email: 'ops@demo.com',
        role: UserRole.opsAdmin,
        emailVerified: true,
      ),
    ),
    'admin@demo.com': _StoredAccount(
      password: 'demo123',
      user: const User(
        id: 'u-ops-legacy',
        name: 'Demo Ops Admin',
        email: 'admin@demo.com',
        role: UserRole.opsAdmin,
        emailVerified: true,
      ),
    ),
    'super@demo.com': _StoredAccount(
      password: 'demo123',
      user: const User(
        id: 'u-super',
        name: 'Demo Super Admin',
        email: 'super@demo.com',
        role: UserRole.superAdmin,
        emailVerified: true,
      ),
    ),
  };

  final Map<String, String> _otps = {};

  @override
  Future<User?> getCurrentUser() async => _current;

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    if (DemoHub.instance.isLoginLocked(key)) {
      throw Exception(
        'This account is deactivated. Contact Digititan to request unlock, '
        'or wait until an Ops Admin reactivates you.',
      );
    }
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
    String? academyName,
    String? resellerKind,
  }) async {
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw Exception('An account with this email already exists');
    }
    if (role.isAdmin) {
      throw Exception('Admin accounts are created by Super Admin only');
    }

    final user = User(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: key,
      role: role,
      emailVerified: false,
    );

    _accounts[key] = _StoredAccount(password: password, user: user);
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
  Future<void> signOut() async {
    _current = null;
  }

  String? debugOtpFor(String email) => _otps[email.trim().toLowerCase()];
}

class _StoredAccount {
  final String password;
  final User user;
  _StoredAccount({required this.password, required this.user});
}

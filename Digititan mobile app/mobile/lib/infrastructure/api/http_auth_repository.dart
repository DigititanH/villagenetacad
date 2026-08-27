import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../api/api_client.dart';
import '../api/token_store.dart';

/// Live auth against Village NetAcad `/api/auth/*` (same as the website).
class HttpAuthRepository implements AuthRepository {
  final ApiClient _api;
  final TokenStore _tokens;
  User? _current;

  HttpAuthRepository({
    required ApiClient api,
    required TokenStore tokens,
  })  : _api = api,
        _tokens = tokens;

  @override
  Future<User?> getCurrentUser() async {
    if (_current != null) return _current;
    final token = await _tokens.read();
    if (token == null || token.isEmpty) return null;
    try {
      final json = await _api.getJson('/api/auth/me');
      final userJson = json['user'];
      if (userJson is! Map<String, dynamic>) {
        await _tokens.clear();
        return null;
      }
      _current = _mapUser(userJson);
      return _current;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _tokens.clear();
        _current = null;
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final json = await _api.postJson('/api/auth/login', {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    final token = json['token']?.toString();
    final userJson = json['user'];
    if (token == null || token.isEmpty || userJson is! Map<String, dynamic>) {
      throw Exception('Login response missing token/user');
    }
    await _tokens.write(token);
    _current = _mapUser(userJson, emailVerified: true);
    return _current!;
  }

  @override
  Future<User> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? academyName,
  }) async {
    if (role.isAdmin) {
      throw Exception('Admin accounts are created by Super Admin only');
    }
    if (role == UserRole.ambassador) {
      throw Exception('Register as customer, then apply to become an ambassador');
    }

    final body = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': role == UserRole.reseller ? 'reseller' : 'customer',
    };
    if (role == UserRole.reseller) {
      // Optional: linked centre/academy name, or leave blank if independent.
      body['academy'] = (academyName ?? '').trim();
    }

    final json = await _api.postJson('/api/auth/register', body);

    // Reseller pending: website creates account but no JWT until Ops approves.
    if (json['pending'] == true) {
      throw Exception(
        json['message']?.toString() ??
            'Reseller account created. An admin must approve it before you can sign in.',
      );
    }

    final token = json['token']?.toString();
    final userJson = json['user'];
    if (token == null || token.isEmpty || userJson is! Map<String, dynamic>) {
      throw Exception('Register response missing token/user');
    }
    await _tokens.write(token);
    // Website verifies email via link; treat session as usable once JWT exists.
    _current = _mapUser(userJson, emailVerified: true);
    return _current!;
  }

  @override
  Future<User> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    // Live site uses email-link verify, not app OTP. If we already have a JWT
    // session, treat as verified for the prototype bridge.
    final user = await getCurrentUser();
    if (user != null && user.email == email.trim().toLowerCase()) {
      return user;
    }
    throw Exception(
      'Email verification is completed via the link sent to your inbox '
      '(same as the website). Then sign in here.',
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await _api.postJson('/api/auth/logout', {}, auth: true);
    } catch (_) {
      // Stateless logout — ignore network errors.
    }
    await _tokens.clear();
    _current = null;
  }

  User _mapUser(Map<String, dynamic> json, {bool? emailVerified}) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final email = (json['email']?.toString() ?? '').toLowerCase();
    final role = _mapRole(json['role']?.toString());
    final verified = emailVerified ??
        (json['is_verified'] == true ||
            json['is_verified'] == 1 ||
            json['emailVerified'] == true);
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      emailVerified: verified,
    );
  }

  UserRole _mapRole(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'reseller':
        return UserRole.reseller;
      case 'ambassador':
        return UserRole.ambassador;
      case 'admin':
      case 'ops':
      case 'ops_admin':
        return UserRole.opsAdmin;
      case 'super':
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.customer;
    }
  }
}

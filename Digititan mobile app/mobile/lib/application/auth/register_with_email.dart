import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/email_sender.dart';
import '../../domain/repositories/reseller_repository.dart';
import '../../infrastructure/api/http_auth_repository.dart';
import '../../infrastructure/dummy/dummy_auth_repository.dart';
import '../../shared/result/result.dart';
import '../../shared/utils/friendly_api_error.dart';

/// Register flow:
/// - Dummy: create unverified user → optional reseller apply → OTP email
/// - Live API: POST /api/auth/register with reseller_kind + academy
class RegisterWithEmail {
  final AuthRepository _authRepository;
  final EmailSender _emailSender;
  final ResellerRepository _resellerRepository;

  RegisterWithEmail(
    this._authRepository,
    this._emailSender,
    this._resellerRepository,
  );

  Future<Result<User>> call({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? academyName,
    String? resellerKind,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.length < 6) {
      return const Failure('Name, email and password (min 6) are required');
    }

    if (role == UserRole.reseller) {
      final kind = (resellerKind ?? 'independent').trim().toLowerCase();
      final academy = (academyName ?? '').trim();
      if (kind == 'affiliated' && academy.isEmpty) {
        return const Failure(
          'Enter the centre / academy you are affiliated with',
        );
      }
      if (kind == 'centre' && academy.isEmpty) {
        return const Failure('Enter your centre / academy organisation name');
      }
    }

    try {
      final user = await _authRepository.registerWithEmail(
        name: name,
        email: email,
        password: password,
        role: role,
        academyName: academyName,
        resellerKind: resellerKind,
      );

      // Dummy path only — live API already creates reseller_profiles.
      if (role == UserRole.reseller && _authRepository is DummyAuthRepository) {
        await _resellerRepository.applyToBecomeReseller(
          name: name,
          email: email,
          academyName: academyName,
        );
      }

      if (_authRepository is HttpAuthRepository) {
        return Success(user);
      }

      final otp = _authRepository is DummyAuthRepository
          ? (_authRepository.debugOtpFor(email) ?? '123456')
          : '******';

      await _emailSender.send(
        to: user.email,
        subject: 'Digititan verification code',
        body:
            'Your verification OTP is: $otp\nIt expires in 10 minutes (prototype).',
      );

      return Success(user);
    } catch (e) {
      return Failure(friendlyApiError(e));
    }
  }
}

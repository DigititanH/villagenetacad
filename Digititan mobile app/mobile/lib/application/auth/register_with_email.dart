import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/email_sender.dart';
import '../../domain/repositories/reseller_repository.dart';
import '../../infrastructure/dummy/dummy_auth_repository.dart';
import '../../shared/result/result.dart';

/// Register flow:
/// 1) create unverified user
/// 2) if reseller → submit application (pending until Ops Admin issues code)
/// 3) send OTP email (event-driven)
/// 4) UI navigates to OTP screen
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
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.length < 6) {
      return const Failure('Name, email and password (min 6) are required');
    }

    try {
      final user = await _authRepository.registerWithEmail(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      if (role == UserRole.reseller) {
        await _resellerRepository.applyToBecomeReseller(
          name: name,
          email: email,
          academyName: academyName,
        );
      }

      // Prototype OTP is fixed in DummyAuthRepository ("123456").
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
      return Failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

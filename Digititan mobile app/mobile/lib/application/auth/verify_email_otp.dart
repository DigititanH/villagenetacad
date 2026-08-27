import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../shared/result/result.dart';

class VerifyEmailOtp {
  final AuthRepository _authRepository;

  VerifyEmailOtp(this._authRepository);

  Future<Result<User>> call({
    required String email,
    required String otp,
  }) async {
    if (otp.trim().length < 4) {
      return const Failure('Enter the OTP from your email');
    }
    try {
      final user = await _authRepository.verifyEmailOtp(email: email, otp: otp);
      return Success(user);
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

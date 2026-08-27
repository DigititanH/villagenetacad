import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../shared/result/result.dart';
import '../../shared/utils/friendly_api_error.dart';

/// One use-case = one business action (SOLID S).
/// Presentation calls this — not the repository directly.
class SignInWithEmail {
  final AuthRepository _authRepository;

  SignInWithEmail(this._authRepository);

  Future<Result<User>> call({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return const Failure('Email and password are required');
    }
    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      return Success(user);
    } catch (e) {
      return Failure(friendlyApiError(e));
    }
  }
}

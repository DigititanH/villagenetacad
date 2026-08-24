import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../shared/result/result.dart';

class SignInWithGoogle {
  final AuthRepository _authRepository;

  SignInWithGoogle(this._authRepository);

  Future<Result<User>> call() async {
    try {
      final user = await _authRepository.signInWithGoogle();
      return Success(user);
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

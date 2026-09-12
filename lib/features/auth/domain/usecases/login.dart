import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class Login {
  const Login(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call({required String email, required String password}) =>
      _repo.login(email: email, password: password);
}

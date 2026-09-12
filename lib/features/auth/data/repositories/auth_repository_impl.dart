import '../../../../core/auth/token_manager.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokens);

  final AuthRemoteDataSource _remote;
  final TokenManager _tokens;

  @override
  Future<Result<void>> login({required String email, required String password}) =>
      guard(() async {
        final tokens = await _remote.login(email: email, password: password);
        await _tokens.saveTokens(tokens);
      });

  @override
  Future<void> logout() => _tokens.signOut();
}

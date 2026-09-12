import '../../../../core/error/result.dart';

abstract interface class AuthRepository {
  Future<Result<void>> login({required String email, required String password});
  Future<void> logout();
}

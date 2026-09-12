import 'package:dio/dio.dart';

import '../../../../core/network/auth_interceptor.dart';
import '../../domain/entities/auth_tokens.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthTokens> login({required String email, required String password});

  /// Ném [DioException] 401/403 khi refresh token hết hạn/bị thu hồi.
  Future<AuthTokens> refresh(String refreshToken);
}

/// Implement thật — dùng khi có backend. Nhận Dio "trần" (không AuthInterceptor).
final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  static final _noAuth = Options(extra: {AuthInterceptor.noAuth: true});

  @override
  Future<AuthTokens> login({required String email, required String password}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: _noAuth,
    );
    return _parse(res.data!);
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: _noAuth,
    );
    return _parse(res.data!);
  }

  AuthTokens _parse(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}

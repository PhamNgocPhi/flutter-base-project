import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/auth/jwt.dart';
import '../../domain/entities/auth_tokens.dart';
import 'auth_remote_datasource.dart';

/// Mock cho base app: tự sinh JWT giả, không gọi mạng.
/// - Login: email/password bất kỳ (không rỗng) đều thành công.
/// - Refresh: refresh token còn hạn → cấp cặp mới (rotate); hết hạn → 401.
final class AuthMockDataSource implements AuthRemoteDataSource {
  AuthMockDataSource({
    this.accessTtl = const Duration(minutes: 1),
    this.refreshTtl = const Duration(days: 7),
    this.latency = const Duration(milliseconds: 400),
  });

  final Duration accessTtl;
  final Duration refreshTtl;
  final Duration latency;

  @override
  Future<AuthTokens> login({required String email, required String password}) async {
    await Future<void>.delayed(latency);
    if (email.isEmpty || password.isEmpty) {
      throw _error('/auth/login', 400, 'Email/mật khẩu không được trống');
    }
    return _issue(email);
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    await Future<void>.delayed(latency);
    final jwt = Jwt.tryDecode(refreshToken);
    if (jwt == null || jwt.payload['typ'] != 'refresh' || jwt.isExpired()) {
      throw _error('/auth/refresh', 401, 'Refresh token hết hạn');
    }
    return _issue(jwt.payload['sub'] as String);
  }

  AuthTokens _issue(String subject) => AuthTokens(
        accessToken: fakeJwt(sub: subject, typ: 'access', ttl: accessTtl),
        refreshToken: fakeJwt(sub: subject, typ: 'refresh', ttl: refreshTtl),
      );

  /// JWT không ký (signature giả) — chỉ để client decode `exp`.
  static String fakeJwt({required String sub, required String typ, required Duration ttl}) {
    final now = DateTime.now().toUtc();
    String enc(Map<String, Object> m) =>
        base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
    final header = enc({'alg': 'none', 'typ': 'JWT'});
    final payload = enc({
      'sub': sub,
      'typ': typ,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(ttl).millisecondsSinceEpoch ~/ 1000,
    });
    return '$header.$payload.mock';
  }

  DioException _error(String path, int status, String message) {
    final req = RequestOptions(path: path);
    return DioException(
      requestOptions: req,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: req, statusCode: status, data: {'message': message}),
    );
  }
}

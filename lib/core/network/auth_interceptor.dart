import 'package:dio/dio.dart';

import '../auth/token_manager.dart';

/// Gắn Bearer token (proactive refresh nếu sắp hết hạn) và retry 1 lần khi 401.
/// Request đánh dấu `extra[noAuth] = true` (login, refresh) bị bỏ qua hoàn toàn.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens, this._dio);

  static const noAuth = 'noAuth';
  static const _retried = 'retried';

  final TokenManager _tokens;
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[noAuth] == true) return handler.next(options);
    final token = await _tokens.validAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final skip = err.response?.statusCode != 401 ||
        req.extra[noAuth] == true ||
        req.extra[_retried] == true;
    if (skip) return handler.next(err);

    final String? newToken;
    try {
      newToken = await _tokens.refresh();
    } on DioException catch (e) {
      return handler.next(e); // lỗi mạng khi refresh
    }
    if (newToken == null) return handler.next(err); // session expired, đã bắn event

    req.headers['Authorization'] = 'Bearer $newToken';
    req.extra[_retried] = true;
    try {
      handler.resolve(await _dio.fetch<dynamic>(req));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

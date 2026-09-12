import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../auth/token_manager.dart';
import '../env/app_env.dart';
import '../logger/app_logger.dart';
import 'auth_interceptor.dart';

/// Dio "trần": chỉ baseUrl/timeout/log. Dùng cho login/refresh để tránh vòng lặp interceptor.
Dio createPlainDio({required AppEnv env, required AppLogger logger}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: Duration(milliseconds: env.apiTimeoutMs),
      receiveTimeout: Duration(milliseconds: env.apiTimeoutMs),
      headers: {'Accept': 'application/json'},
    ),
  );
  if (env.enableLog) {
    dio.interceptors.add(
      TalkerDioLogger(
        talker: logger.talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: false,
          printResponseData: false,
        ),
      ),
    );
  }
  return dio;
}

/// Dio chính cho toàn app: có AuthInterceptor.
Dio createAuthedDio({
  required AppEnv env,
  required AppLogger logger,
  required TokenManager tokens,
}) {
  final dio = createPlainDio(env: env, logger: logger);
  dio.interceptors.insert(0, AuthInterceptor(tokens, dio));
  return dio;
}

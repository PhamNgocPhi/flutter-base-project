import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_mock_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/example/data/datasources/example_remote_datasource.dart';
import '../../features/example/data/repositories/example_repository_impl.dart';
import '../../features/example/domain/repositories/example_repository.dart';
import '../../features/example/domain/usecases/get_examples.dart';
import '../auth/token_manager.dart';
import '../env/app_env.dart';
import '../logger/app_logger.dart';
import '../network/dio_client.dart';
import '../storage/app_storage.dart';

final getIt = GetIt.instance;

/// Tên instance cho Dio không có AuthInterceptor (dùng cho login/refresh).
const plainDio = 'plainDio';

/// Đăng ký thủ công, theo thứ tự: env -> infra -> auth -> feature.
/// Khi số feature lớn, tách mỗi feature thành `registerXxxModule(getIt)`.
Future<void> configureDependencies(AppEnv env) async {
  // Env & logger
  getIt
    ..registerSingleton<AppEnv>(env)
    ..registerSingleton<AppLogger>(AppLogger(enabled: env.enableLog));

  // Storage
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<AppStorage>(
    AppStorage(prefs: prefs, secure: const FlutterSecureStorage()),
  );

  // Auth + network (thứ tự quan trọng: TokenManager cần datasource, Dio chính cần TokenManager)
  getIt
    ..registerLazySingleton<Dio>(
      () => createPlainDio(env: env, logger: getIt()),
      instanceName: plainDio,
    )
    // Đổi sang AuthRemoteDataSourceImpl(getIt(instanceName: plainDio)) khi có backend thật
    ..registerLazySingleton<AuthRemoteDataSource>(AuthMockDataSource.new)
    ..registerLazySingleton<TokenManager>(
      () => TokenManager(getIt(), getIt()),
      dispose: (m) => m.dispose(),
    )
    ..registerLazySingleton<Dio>(
      () => createAuthedDio(env: env, logger: getIt(), tokens: getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt(), getIt()),
    )
    ..registerFactory(() => Login(getIt()))
    ..registerFactory(() => Logout(getIt()));

  // Feature: example
  getIt
    ..registerLazySingleton<ExampleRemoteDataSource>(
      () => ExampleRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<ExampleRepository>(
      () => ExampleRepositoryImpl(getIt()),
    )
    ..registerFactory(() => GetExamples(getIt()));
}

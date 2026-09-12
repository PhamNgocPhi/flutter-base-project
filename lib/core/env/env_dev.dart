import 'package:envied/envied.dart';

import 'app_env.dart';

part 'env_dev.g.dart';

@Envied(path: 'env/.env.dev', obfuscate: true)
final class EnvDev extends AppEnv {
  @EnviedField(varName: 'API_BASE_URL')
  static final String _apiBaseUrl = _EnvDev._apiBaseUrl;
  @EnviedField(varName: 'API_TIMEOUT_MS')
  static final int _apiTimeoutMs = _EnvDev._apiTimeoutMs;
  @EnviedField(varName: 'ENABLE_LOG')
  static final bool _enableLog = _EnvDev._enableLog;

  @override
  Flavor get flavor => Flavor.dev;
  @override
  String get apiBaseUrl => _apiBaseUrl;
  @override
  int get apiTimeoutMs => _apiTimeoutMs;
  @override
  bool get enableLog => _enableLog;
}

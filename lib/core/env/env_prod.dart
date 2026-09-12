import 'package:envied/envied.dart';

import 'app_env.dart';

part 'env_prod.g.dart';

@Envied(path: 'env/.env.prod', obfuscate: true)
final class EnvProd extends AppEnv {
  @EnviedField(varName: 'API_BASE_URL')
  static final String _apiBaseUrl = _EnvProd._apiBaseUrl;
  @EnviedField(varName: 'API_TIMEOUT_MS')
  static final int _apiTimeoutMs = _EnvProd._apiTimeoutMs;
  @EnviedField(varName: 'ENABLE_LOG')
  static final bool _enableLog = _EnvProd._enableLog;

  @override
  Flavor get flavor => Flavor.prod;
  @override
  String get apiBaseUrl => _apiBaseUrl;
  @override
  int get apiTimeoutMs => _apiTimeoutMs;
  @override
  bool get enableLog => _enableLog;
}

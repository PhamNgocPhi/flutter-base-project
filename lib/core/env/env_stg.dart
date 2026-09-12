import 'package:envied/envied.dart';

import 'app_env.dart';

part 'env_stg.g.dart';

@Envied(path: 'env/.env.stg', obfuscate: true)
final class EnvStg extends AppEnv {
  @EnviedField(varName: 'API_BASE_URL')
  static final String _apiBaseUrl = _EnvStg._apiBaseUrl;
  @EnviedField(varName: 'API_TIMEOUT_MS')
  static final int _apiTimeoutMs = _EnvStg._apiTimeoutMs;
  @EnviedField(varName: 'ENABLE_LOG')
  static final bool _enableLog = _EnvStg._enableLog;

  @override
  Flavor get flavor => Flavor.stg;
  @override
  String get apiBaseUrl => _apiBaseUrl;
  @override
  int get apiTimeoutMs => _apiTimeoutMs;
  @override
  bool get enableLog => _enableLog;
}

enum Flavor { dev, stg, prod }

/// Config theo flavor. Giá trị được envied sinh ra từ `env/.env.<flavor>` tại build time.
abstract class AppEnv {
  Flavor get flavor;
  String get apiBaseUrl;
  int get apiTimeoutMs;
  bool get enableLog;

  bool get isProd => flavor == Flavor.prod;
  String get name => flavor.name;
}

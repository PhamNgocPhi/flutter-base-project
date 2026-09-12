import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gom prefs (dữ liệu thường) và secure storage (token, secret) vào một chỗ.
class AppStorage {
  AppStorage({required this.prefs, required this.secure});

  final SharedPreferences prefs;
  final FlutterSecureStorage secure;

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kThemeMode = 'theme_mode';

  Future<String?> getAccessToken() => secure.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => secure.read(key: _kRefreshToken);

  Future<void> setTokens({required String access, required String refresh}) =>
      Future.wait([
        secure.write(key: _kAccessToken, value: access),
        secure.write(key: _kRefreshToken, value: refresh),
      ]);

  Future<void> clearTokens() => Future.wait([
        secure.delete(key: _kAccessToken),
        secure.delete(key: _kRefreshToken),
      ]);

  String? get themeMode => prefs.getString(_kThemeMode);
  Future<void> setThemeMode(String value) => prefs.setString(_kThemeMode, value);
}

import 'package:fluenary/core/storage/app_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSecure extends Mock implements FlutterSecureStorage {}

/// AppStorage chạy trên Map trong RAM cho test.
Future<AppStorage> inMemoryStorage() async {
  SharedPreferences.setMockInitialValues({});
  final map = <String, String>{};
  final secure = _MockSecure();
  when(() => secure.read(key: any(named: 'key')))
      .thenAnswer((i) async => map[i.namedArguments[#key]]);
  when(() => secure.write(key: any(named: 'key'), value: any(named: 'value')))
      .thenAnswer((i) async {
    map[i.namedArguments[#key] as String] = i.namedArguments[#value] as String;
  });
  when(() => secure.delete(key: any(named: 'key')))
      .thenAnswer((i) async => map.remove(i.namedArguments[#key]));
  return AppStorage(prefs: await SharedPreferences.getInstance(), secure: secure);
}

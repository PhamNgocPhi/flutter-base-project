import 'package:dio/dio.dart';
import 'package:fluenary/core/auth/token_manager.dart';
import 'package:fluenary/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:fluenary/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fluenary/features/auth/domain/entities/auth_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_storage.dart';

/// Datasource đếm số lần refresh, có thể ép lỗi.
class _CountingDataSource implements AuthRemoteDataSource {
  int refreshCalls = 0;
  Object? nextError;

  @override
  Future<AuthTokens> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (nextError case final e?) throw e;
    return AuthTokens(
      accessToken: AuthMockDataSource.fakeJwt(
          sub: 'u', typ: 'access', ttl: const Duration(minutes: 5)),
      refreshToken: 'rt-$refreshCalls',
    );
  }
}

DioException _http(int status) {
  final req = RequestOptions(path: '/auth/refresh');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: req, statusCode: status),
  );
}

void main() {
  late _CountingDataSource remote;
  late TokenManager manager;
  late List<AuthEvent> events;

  setUp(() async {
    remote = _CountingDataSource();
    final storage = await inMemoryStorage();
    await storage.setTokens(access: 'old', refresh: 'rt-0');
    manager = TokenManager(storage, remote);
    events = [];
    manager.events.listen(events.add);
  });

  test('5 lần refresh đồng thời chỉ gọi datasource 1 lần', () async {
    final results = await Future.wait(List.generate(5, (_) => manager.refresh()));
    expect(remote.refreshCalls, 1);
    expect(results.toSet().length, 1);
    expect(await manager.accessToken, results.first);
  });

  test('refresh tuần tự thì gọi lại datasource', () async {
    await manager.refresh();
    await manager.refresh();
    expect(remote.refreshCalls, 2);
  });

  test('refresh 401 → xoá token + sessionExpired', () async {
    remote.nextError = _http(401);
    expect(await manager.refresh(), isNull);
    expect(await manager.hasSession, isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(events, [AuthEvent.sessionExpired]);
  });

  test('refresh lỗi mạng → ném lỗi, KHÔNG logout', () async {
    remote.nextError = DioException(
      requestOptions: RequestOptions(path: '/auth/refresh'),
      type: DioExceptionType.connectionError,
    );
    await expectLater(manager.refresh(), throwsA(isA<DioException>()));
    expect(await manager.hasSession, isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty);
  });

  test('validAccessToken refresh trước khi hết hạn (proactive)', () async {
    final storage = await inMemoryStorage();
    await storage.setTokens(
      access: AuthMockDataSource.fakeJwt(
          sub: 'u', typ: 'access', ttl: const Duration(seconds: 10)), // < leeway 30s
      refresh: 'rt-0',
    );
    manager = TokenManager(storage, remote);
    final token = await manager.validAccessToken();
    expect(remote.refreshCalls, 1);
    expect(token, isNot('old'));
  });

  test('validAccessToken không refresh khi còn hạn', () async {
    final storage = await inMemoryStorage();
    final access = AuthMockDataSource.fakeJwt(
        sub: 'u', typ: 'access', ttl: const Duration(minutes: 5));
    await storage.setTokens(access: access, refresh: 'rt-0');
    manager = TokenManager(storage, remote);
    expect(await manager.validAccessToken(), access);
    expect(remote.refreshCalls, 0);
  });
}

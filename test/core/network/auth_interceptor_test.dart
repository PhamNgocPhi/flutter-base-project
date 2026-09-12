import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fluenary/core/auth/token_manager.dart';
import 'package:fluenary/core/network/auth_interceptor.dart';
import 'package:fluenary/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_storage.dart';

/// Adapter giả: lần gọi đầu trả 401, từ lần 2 trả 200. Ghi lại header Authorization.
class _SecondCallOkAdapter implements HttpClientAdapter {
  int calls = 0;
  final tokens = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    tokens.add(o.headers['Authorization'] as String?);
    final ok = calls >= 2;
    return ResponseBody.fromString(
      jsonEncode({'ok': ok}),
      ok ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late _SecondCallOkAdapter adapter;

  setUp(() async {
    final storage = await inMemoryStorage();
    // access còn hạn (không proactive), refresh còn hạn
    await storage.setTokens(
      access: AuthMockDataSource.fakeJwt(
          sub: 'u', typ: 'access', ttl: const Duration(minutes: 5)),
      refresh: AuthMockDataSource.fakeJwt(
          sub: 'u', typ: 'refresh', ttl: const Duration(days: 1)),
    );
    final tokens =
        TokenManager(storage, AuthMockDataSource(latency: Duration.zero));
    adapter = _SecondCallOkAdapter();
    dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(tokens, dio));
  });

  test('401 → refresh → retry 1 lần với token mới', () async {
    final res = await dio.get<Map<String, dynamic>>('/me');
    expect(res.statusCode, 200);
    expect(adapter.calls, 2);
    expect(adapter.tokens[0], startsWith('Bearer '));
    expect(adapter.tokens[1], isNot(adapter.tokens[0]));
  });

  test('noAuth request không gắn header, không retry', () async {
    await expectLater(
      dio.get<dynamic>(
        '/auth/login',
        options: Options(extra: {AuthInterceptor.noAuth: true}),
      ),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 1);
    expect(adapter.tokens.single, isNull);
  });
}

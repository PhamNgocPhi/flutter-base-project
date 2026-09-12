import 'dart:async';

import 'package:dio/dio.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/domain/entities/auth_tokens.dart';
import '../storage/app_storage.dart';
import 'jwt.dart';

enum AuthEvent { signedIn, sessionExpired, signedOut }

/// Quản lý vòng đời token. Không biết gì về UI; UI nghe [events].
///
/// - [refresh]: nhiều caller đồng thời chỉ tạo đúng 1 request refresh (lock bằng Completer).
/// - Refresh trả 401/403 → token chết → xoá + bắn [AuthEvent.sessionExpired].
/// - Refresh lỗi mạng → KHÔNG logout, ném lỗi để request gốc fail bình thường.
final class TokenManager {
  TokenManager(this._storage, this._remote);

  final AppStorage _storage;
  final AuthRemoteDataSource _remote;

  /// Refresh trước khi access token hết hạn bao lâu (proactive).
  static const refreshLeeway = Duration(seconds: 30);

  Completer<String?>? _refreshing;
  final _events = StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get events => _events.stream;

  Future<String?> get accessToken => _storage.getAccessToken();

  Future<bool> get hasSession async => await _storage.getRefreshToken() != null;

  /// Access token còn dùng được. Nếu sắp hết hạn thì refresh trước (proactive).
  Future<String?> validAccessToken() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    final jwt = Jwt.tryDecode(token);
    if (jwt != null && jwt.isExpired(leeway: refreshLeeway)) {
      try {
        return await refresh();
      } on DioException {
        return token; // lỗi mạng: cứ dùng token cũ, server sẽ trả 401 nếu thật sự hết hạn
      }
    }
    return token;
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.setTokens(access: tokens.accessToken, refresh: tokens.refreshToken);
    _events.add(AuthEvent.signedIn);
  }

  Future<void> signOut() async {
    await _storage.clearTokens();
    _events.add(AuthEvent.signedOut);
  }

  /// Trả về access token mới, hoặc null nếu refresh token đã chết.
  /// Ném [DioException] khi lỗi mạng.
  Future<String?> refresh() {
    final inflight = _refreshing;
    if (inflight != null) return inflight.future;

    final completer = _refreshing = Completer<String?>();
    _doRefresh().then(completer.complete, onError: completer.completeError).whenComplete(() {
      _refreshing = null;
    });
    return completer.future;
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return _expire();
    try {
      final tokens = await _remote.refresh(refreshToken);
      await _storage.setTokens(access: tokens.accessToken, refresh: tokens.refreshToken);
      return tokens.accessToken;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) return _expire();
      rethrow;
    }
  }

  Future<String?> _expire() async {
    await _storage.clearTokens();
    _events.add(AuthEvent.sessionExpired);
    return null;
  }

  void dispose() => _events.close();
}

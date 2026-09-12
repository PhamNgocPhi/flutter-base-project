import 'dart:convert';

/// Decode payload JWT (không verify chữ ký — client chỉ cần đọc `exp`).
final class Jwt {
  const Jwt._(this.payload);

  final Map<String, dynamic> payload;

  static Jwt? tryDecode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return Jwt._(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  DateTime? get expiresAt {
    final exp = payload['exp'];
    return exp is num
        ? DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true)
        : null;
  }

  /// Hết hạn (hoặc sẽ hết hạn trong [leeway]). Không có `exp` → coi như còn hạn.
  bool isExpired({Duration leeway = Duration.zero}) {
    final exp = expiresAt;
    return exp != null && DateTime.now().toUtc().add(leeway).isAfter(exp);
  }
}

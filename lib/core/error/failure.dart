import 'package:dio/dio.dart';

/// Lỗi đã được chuẩn hoá để UI hiển thị. Dùng `switch` pattern matching.
sealed class Failure {
  const Failure(this.message);
  final String message;

  factory Failure.fromException(Object e) => switch (e) {
        DioException(type: DioExceptionType.connectionTimeout) ||
        DioException(type: DioExceptionType.receiveTimeout) ||
        DioException(type: DioExceptionType.connectionError) =>
          const NetworkFailure(),
        DioException(response: final r?) => ServerFailure(
            statusCode: r.statusCode,
            message: _extractMessage(r.data) ?? 'Lỗi máy chủ',
          ),
        Failure() => e,
        _ => UnknownFailure(e.toString()),
      };

  static String? _extractMessage(Object? data) =>
      data is Map ? data['message']?.toString() : null;
}

final class NetworkFailure extends Failure {
  const NetworkFailure() : super('Không có kết nối mạng');
}

final class ServerFailure extends Failure {
  const ServerFailure({required this.statusCode, required String message})
      : super(message);
  final int? statusCode;
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

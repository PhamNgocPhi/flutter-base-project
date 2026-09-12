import 'failure.dart';

/// Kết quả của usecase/repository. Bloc `switch` trên type này thay vì try/catch.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}

/// Bọc một async call, map exception -> Failure.
Future<Result<T>> guard<T>(Future<T> Function() run) async {
  try {
    return Success(await run());
  } catch (e) {
    return Error(Failure.fromException(e));
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/usecases/login.dart';

sealed class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

final class LoginIdle extends LoginState {
  const LoginIdle();
}

final class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

final class LoginFailed extends LoginState {
  const LoginFailed(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

/// State của form login. Thành công không cần state riêng: TokenManager bắn
/// signedIn → AuthCubit đổi state → router tự redirect.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._login) : super(const LoginIdle());

  final Login _login;

  Future<void> submit({required String email, required String password}) async {
    emit(const LoginSubmitting());
    final result = await _login(email: email, password: password);
    emit(switch (result) {
      Success() => const LoginIdle(),
      Error(:final failure) => LoginFailed(failure),
    });
  }
}

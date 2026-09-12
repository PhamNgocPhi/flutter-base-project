import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/token_manager.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Chưa đọc xong storage — splash chờ state này đổi.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class Authenticated extends AuthState {
  const Authenticated();
}

final class Unauthenticated extends AuthState {
  const Unauthenticated({this.sessionExpired = false});
  final bool sessionExpired;
  @override
  List<Object?> get props => [sessionExpired];
}

/// Nguồn sự thật về "đã đăng nhập hay chưa" cho toàn app. Router redirect dựa vào đây.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._tokens) : super(const AuthUnknown()) {
    _sub = _tokens.events.listen(_onEvent);
    unawaited(_init());
  }

  final TokenManager _tokens;
  late final StreamSubscription<AuthEvent> _sub;

  Future<void> _init() async {
    emit(await _tokens.hasSession ? const Authenticated() : const Unauthenticated());
  }

  void _onEvent(AuthEvent event) => emit(switch (event) {
        AuthEvent.signedIn => const Authenticated(),
        AuthEvent.signedOut => const Unauthenticated(),
        AuthEvent.sessionExpired => const Unauthenticated(sessionExpired: true),
      });

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

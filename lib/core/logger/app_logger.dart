import 'package:talker_flutter/talker_flutter.dart';

/// Wrapper cho Talker. Dùng `getIt<AppLogger>()` hoặc inject vào constructor.
final class AppLogger {
  AppLogger({required bool enabled})
      : talker = TalkerFlutter.init(
          settings: TalkerSettings(enabled: enabled, useConsoleLogs: enabled),
        );

  final Talker talker;

  void d(Object msg) => talker.debug(msg);
  void i(Object msg) => talker.info(msg);
  void w(Object msg, [Object? e, StackTrace? st]) => talker.warning(msg, e, st);
  void e(Object msg, [Object? e, StackTrace? st]) => talker.error(msg, e, st);
}

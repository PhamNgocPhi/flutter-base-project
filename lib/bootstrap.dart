import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

import 'app/app.dart';
import 'core/di/injection.dart';
import 'core/env/app_env.dart';
import 'core/logger/app_logger.dart';

/// Điểm khởi động chung cho mọi flavor. Mọi init (Firebase, Hive, ...) thêm vào đây.
Future<void> bootstrap(AppEnv env) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await configureDependencies(env);
      final talker = getIt<AppLogger>().talker;

      FlutterError.onError = (details) {
        talker.handle(details.exception, details.stack, 'FlutterError');
        if (kDebugMode) FlutterError.presentError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        talker.handle(error, stack, 'PlatformDispatcher');
        return true;
      };
      Bloc.observer = TalkerBlocObserver(
        talker: talker,
        settings: const TalkerBlocLoggerSettings(printStateFullData: false),
      );

      talker.info('Bootstrap [${env.name}] -> ${env.apiBaseUrl}');
      runApp(const App());
    },
    (error, stack) {
      getIt<AppLogger>().talker.handle(error, stack, 'Zone');
    },
  );
}

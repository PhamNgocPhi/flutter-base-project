import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../core/di/injection.dart';
import '../../core/logger/app_logger.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/example/presentation/screens/example_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'go_router_refresh_stream.dart';
import 'routes.dart';

GoRouter createRouter(AuthCubit auth) => GoRouter(
      initialLocation: Routes.splash,
      observers: [TalkerRouteObserver(getIt<AppLogger>().talker)],
      // Re-evaluate redirect mỗi khi AuthCubit đổi state
      refreshListenable: GoRouterRefreshStream(auth.stream),
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final isPublic = Routes.public.contains(loc);
        return switch (auth.state) {
          AuthUnknown() => loc == Routes.splash ? null : Routes.splash,
          Unauthenticated() => loc == Routes.login ? null : Routes.login,
          Authenticated() => isPublic ? Routes.home : null,
        };
      },
      routes: [
        GoRoute(
          path: Routes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: Routes.example,
          builder: (context, state) => const ExampleScreen(),
        ),
        GoRoute(
          path: Routes.logs,
          builder: (context, state) =>
              TalkerScreen(talker: getIt<AppLogger>().talker),
        ),
      ],
    );


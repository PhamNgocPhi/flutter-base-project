import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/settings/presentation/cubit/theme_cubit.dart';
import '../generated/l10n.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _auth = AuthCubit(getIt());
  late final GoRouter _router = createRouter(_auth);

  @override
  void dispose() {
    _router.dispose();
    _auth.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Cubit toàn app (auth, theme, ...) đặt ở đây
        BlocProvider.value(value: _auth),
        BlocProvider(create: (_) => ThemeCubit(getIt())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp.router(
          onGenerateTitle: (context) => S.of(context).appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: _router,
          locale: const Locale('vi'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => BlocListener<AuthCubit, AuthState>(
            listenWhen: (_, s) => s is Unauthenticated && s.sessionExpired,
            listener: (context, _) => ScaffoldMessenger.maybeOf(context)
                ?.showSnackBar(SnackBar(content: Text(S.of(context).sessionExpired))),
            child: child!,
          ),
        ),
      ),
    );
  }
}

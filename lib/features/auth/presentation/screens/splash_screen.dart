import 'package:flutter/material.dart';

import '../../../../core/widgets/app_loading.dart';

/// Hiện trong lúc AuthCubit đọc storage (AuthUnknown). Router tự chuyển đi.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: AppLoading());
}

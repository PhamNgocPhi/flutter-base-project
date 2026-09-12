import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/env/app_env.dart';
import '../../../../core/utils/context_ext.dart';
import '../cubit/counter_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.home),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push(Routes.settings),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.environment(getIt<AppEnv>().name),
                style: context.text.bodySmall,
              ),
              const SizedBox(height: 16),
              BlocBuilder<CounterCubit, int>(
                builder: (context, count) => Text(
                  context.l10n.counter(count),
                  style: context.text.titleLarge,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.push(Routes.example),
                child: Text(context.l10n.example),
              ),
              TextButton(
                onPressed: () => context.push(Routes.logs),
                child: Text(context.l10n.logs),
              ),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: context.read<CounterCubit>().increment,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

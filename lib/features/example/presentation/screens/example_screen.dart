import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../bloc/example_bloc.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExampleBloc(getIt())..add(const ExampleRequested()),
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.example)),
        body: BlocBuilder<ExampleBloc, ExampleState>(
          builder: (context, state) => switch (state) {
            ExampleInitial() || ExampleLoading() => const AppLoading(),
            ExampleFailure(:final failure) => AppErrorView(
                message: failure.message,
                onRetry: () =>
                    context.read<ExampleBloc>().add(const ExampleRequested()),
              ),
            ExampleLoaded(:final items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(child: Text('${items[i].id}')),
                  title: Text(items[i].title),
                ),
              ),
          },
        ),
      ),
    );
  }
}

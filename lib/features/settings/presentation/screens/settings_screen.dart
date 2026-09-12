import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/context_ext.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../cubit/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      ThemeMode.system: l10n.themeSystem,
      ThemeMode.light: l10n.themeLight,
      ThemeMode.dark: l10n.themeDark,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => RadioGroup<ThemeMode>(
          groupValue: mode,
          onChanged: (m) => context.read<ThemeCubit>().setMode(m!),
          child: ListView(
            children: [
              ListTile(title: Text(l10n.theme)),
              for (final entry in labels.entries)
                RadioListTile<ThemeMode>(
                  title: Text(entry.value),
                  value: entry.key,
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.logout),
                onTap: () => getIt<Logout>()(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

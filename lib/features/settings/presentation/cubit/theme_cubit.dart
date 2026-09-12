import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/app_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(_read(_storage));

  final AppStorage _storage;

  static ThemeMode _read(AppStorage storage) => ThemeMode.values.firstWhere(
        (m) => m.name == storage.themeMode,
        orElse: () => ThemeMode.system,
      );

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _storage.setThemeMode(mode.name);
  }
}

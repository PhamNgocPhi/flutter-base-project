import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

extension ContextX on BuildContext {
  S get l10n => S.of(this);
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get text => theme.textTheme;

  void showSnack(String message) => ScaffoldMessenger.of(this)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

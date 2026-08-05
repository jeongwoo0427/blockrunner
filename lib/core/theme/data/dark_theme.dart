import 'package:blockrunner/core/theme/base_theme.dart';
import 'package:blockrunner/core/theme/board_colors.dart';
import 'package:flutter/material.dart';

final ThemeData darkTheme = BaseTheme.build(
  brightness: Brightness.dark,
  boardColors: BoardColors.dark,
);

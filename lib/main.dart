import 'package:flutter/material.dart';

import 'data/theme.dart';
import 'timetable.dart';

void main() async {
  final String themeName = await getThemeName();
  final ThemeData theme = await getThemeByName(themeName);

  runApp(StreamBuilder<ThemeData>(
    stream: bloc.themeEnabled,
    initialData: theme,
    builder: (context, snapshot) => MaterialApp(
      theme: snapshot.data,
      home: TimetablePage(),
    ),
  ));
}

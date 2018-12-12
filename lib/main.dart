import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'timetable.dart';

void main() async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	String themeName = prefs.getString('theme') ?? 'light';

  runApp(StreamBuilder(
      stream: bloc.themeEnabled,
      initialData: themeName,
      builder: (context, snapshot) {
        ThemeData theme = ThemeData();
        if (snapshot.data == 'light') theme = ThemeData(
          primaryColor: Colors.white,
          canvasColor: Colors.grey[200],
        );
        if (snapshot.data == 'dark') theme = ThemeData.dark();
        if (snapshot.data == 'darkBlack') {
          theme = ThemeData.dark().copyWith(
            canvasColor: Colors.black,
            primaryColor: Colors.black,
            scaffoldBackgroundColor: Colors.black,
          );
        }
        print(snapshot.data);
        return MaterialApp(
          theme: theme,
          home: TimetablePage()
        );
      },
    ));
}

class Bloc {
  final _themeController = StreamController<String>();
  get changeTheme => _themeController.sink.add;
  get themeEnabled => _themeController.stream;
}

final bloc = Bloc();

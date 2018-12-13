import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sun_calc.dart';
import 'timetable.dart';

final lightTheme = ThemeData(
	primaryColor: Colors.white,
	canvasColor: Colors.grey[200],
);

final darkTheme = ThemeData.dark();
final darkBlackTheme = ThemeData.dark().copyWith(
	canvasColor: Colors.black,
	primaryColor: Colors.black,
	scaffoldBackgroundColor: Colors.black,
);

Future<ThemeData> getLocationTheme() async {
	final Location location = Location();
	final DateTime now = DateTime.now();
	bool isDay = now.hour > 8 && now.hour < 20;

	try {
		final currentLocation = await location.getLocation();
		SunCalc sunCalc = SunCalc(now, currentLocation['longitude'], currentLocation['latitude']);

		isDay = now.isAfter(sunCalc.times['dawn']) && now.isBefore(sunCalc.times['dusk']);
	} on PlatformException {}
	return isDay ? lightTheme : darkTheme;
}

void main() async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	String themeName = prefs.getString('theme') ?? 'light';

	ThemeData locationBasedTheme = await getLocationTheme();

	runApp(StreamBuilder(
		stream: bloc.themeEnabled,
		initialData: themeName,
		builder: (context, snapshot) {
			ThemeData theme = ThemeData();
			if (snapshot.data == 'light') theme = lightTheme;
			if (snapshot.data == 'dark') theme = darkTheme;
			if (snapshot.data == 'darkBlack') theme = darkBlackTheme;
			if (snapshot.data == 'locationBased') theme = locationBasedTheme;
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
	void c() => _themeController.close();
}

final bloc = Bloc();

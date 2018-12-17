import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../sun_calc.dart';

final themes = {
	'light': ThemeData(
		primaryColor: Colors.white,
		canvasColor: Colors.grey[200],
	),
	'dark': ThemeData.dark(),
	'darkBlack': ThemeData.dark().copyWith(
		canvasColor: Colors.black,
		primaryColor: Colors.black,
		scaffoldBackgroundColor: Colors.black,
	),
};

Future<ThemeData> getThemeByName(String themeName) async {
	if (themeName == 'timeBased') return getTimeTheme();
	return themes[themeName];
}

Future<String> getThemeName() async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	return prefs.getString('theme') ?? 'light';
}

Future<void> saveThemeName(String theme) async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	await prefs.setString('theme', theme);
}

Future<ThemeData> getTimeTheme() async {
	final Location location = Location();
	Map<String, double> currentLocation = {};

	bool isDay;
	int nextTime;
	final int msDay = 1000 * 60 * 60 * 24 * 1000;
	final DateTime now = DateTime.now();
	final DateTime tomorrow = DateTime.fromMicrosecondsSinceEpoch(now.millisecondsSinceEpoch * 1000 + msDay);

	try { currentLocation = await location.getLocation(); } on PlatformException {}

	if (currentLocation.isNotEmpty) {
		SunCalc sunCalcN = SunCalc(now, currentLocation['longitude'], currentLocation['latitude']);
		SunCalc sunCalcT = SunCalc(tomorrow, currentLocation['longitude'], currentLocation['latitude']);

		isDay = now.isAfter(sunCalcN.times['dawn']) && now.isBefore(sunCalcN.times['dusk']);

		if (now.isBefore(sunCalcN.times['dawn'])) nextTime = sunCalcN.times['dawn'].millisecondsSinceEpoch;
		else if (now.isAfter(sunCalcN.times['dusk'])) nextTime = sunCalcT.times['dawn'].millisecondsSinceEpoch;
		else nextTime = sunCalcN.times['dusk'].millisecondsSinceEpoch;
	} else {
		isDay = now.hour > 7 && now.hour < 20;

		if (now.hour < 8) nextTime = DateTime(now.year, now.month, now.day, 8).millisecondsSinceEpoch;
		else if (now.hour > 19) nextTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8).millisecondsSinceEpoch;
		else nextTime = DateTime(now.year, now.month, now.day, 20).millisecondsSinceEpoch;
	}

	print('NOW - $now');
	print('IS DAY - $isDay');
	print('NEXT SWITCH TIME - ${DateTime.fromMillisecondsSinceEpoch(nextTime)}');

	Future.delayed(Duration(milliseconds: nextTime - now.millisecondsSinceEpoch), () async {
		String themeName = await getThemeName();
		if (themeName != 'locationBased') return;
		final ThemeData theme = await getThemeByName('locationBased');
		bloc.changeTheme(theme);
	});
	return themes[isDay ? 'light' : 'dark'];
}

class Bloc {
	final _themeController = StreamController<ThemeData>();
	get changeTheme => _themeController.sink.add;
	get themeEnabled => _themeController.stream;
	void c() => _themeController.close();
}

final bloc = Bloc();

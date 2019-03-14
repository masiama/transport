import 'dart:io';
import 'package:flutter/material.dart';
import 'data/theme.dart';

const Map<String, String> themes = {
	'light': 'Light',
	'dark': 'Dark',
	'darkBlack': 'Dark (pure black)',
	'timeBased': 'Time Based',
};

class _SettingsStatePage extends State<SettingsPage> {
	String _theme;

	@override
	void initState() {
		(() async {
			final String theme = await getThemeName();
			setState(() => _theme = theme);
		})();
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				elevation: Platform.isIOS ? 0 : 4,
				title: const Text('Settings'),
			),
			body: ListView(
				padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
				children: [
					FormField(builder: (state) => InputDecorator(
						decoration: InputDecoration(
							icon: const Icon(Icons.color_lens),
							labelText: 'Theme',
						),
						isEmpty: _theme == '',
						child: DropdownButtonHideUnderline(child: DropdownButton(
							value: _theme,
							isDense: true,
							onChanged: (newValue) async {
								setState(() => _theme = newValue);
								await saveThemeName(newValue);
								final ThemeData theme = await getThemeByName(newValue);
								bloc.changeTheme(theme);
							},
							items: themes.keys.map((key) => DropdownMenuItem(
								value: key,
								child: Text(themes[key]),
							)).toList(),
						)),
					)),
				]
			),
		);
	}
}

class SettingsPage extends StatefulWidget {
	@override
	_SettingsStatePage createState() => _SettingsStatePage();
}

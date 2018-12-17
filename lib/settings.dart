import 'dart:io';
import 'package:flutter/material.dart';
import 'util.dart';
import 'main.dart';

final Map<String, String> themes = {
	'light': 'Light',
	'dark': 'Dark',
	'darkBlack': 'Dark (pure black)',
	'locationBased': 'Location Based',
};

class _SettingsStatePage extends State<SettingsPage> {
	String _theme;

	@override
	void initState() {
		(() async {
			final theme = await getTheme();
			setState(() => _theme = theme);
		})();
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
        elevation: Platform.isIOS ? 0 : 4,
        title: Text('Settings'),
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
								await saveTheme(newValue);
                ThemeData theme = await getThemeByName(newValue);
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

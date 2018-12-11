import 'package:flutter/material.dart';

import 'timetable.dart';

void main() => runApp(TransportApp());

class TransportApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Transport',
			theme: ThemeData.dark(),
			home: TimetablePage(),
		);
	}
}

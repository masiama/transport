import 'dart:io';
import 'package:flutter/material.dart';

import 'util.dart';
import 'num_list.dart';
import 'settings.dart';
import 'fetch.dart';
import 'data/stop.dart';

TimetablePageState timetableState;

class TimetablePageState extends State<TimetablePage> {
	bool update = false;

	void rebuild() {
		setState(() => update = !update);
	}

	Widget loadStacks([FetchResponse data]) {
		timetableState = this;
		return StackPage(data != null ? data : FetchResponse(true));
	}

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
			length: 6,
			child: Scaffold(
				appBar: AppBar(
					elevation: Platform.isIOS ? 0 : 4,
					title: Text('Timetable'),
					bottom: TabBar(tabs: [
						Tab(icon: Icon(Icons.directions_bus, color: colors['bus'])),
						Tab(icon: Icon(Icons.tram, color: colors['tram'])),
						Tab(icon: Icon(Icons.directions_bus, color: colors['trol'])),
						Tab(icon: Icon(Icons.directions_bus, color: colors['minibus'])),
						Tab(icon: Icon(Icons.directions_bus, color: colors['expressbus'])),
						Tab(icon: Icon(Icons.directions_bus, color: colors['nightbus'])),
					]),
					actions: [IconButton(icon: Icon(Icons.settings), onPressed: () {
						Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
					})],
				),
				body: stops.keys.length == 0 ? FutureBuilder<FetchResponse>(
					future: fetchData(),
					builder: (_, snapshot) {
						if (snapshot.connectionState == ConnectionState.done) return loadStacks(snapshot.data);
						return Center(child: CircularProgressIndicator());
					},
				) : loadStacks(),
			),
		);
	}
}

class TimetablePage extends StatefulWidget {
	@override
	TimetablePageState createState() => TimetablePageState();
}

class StackPage extends StatelessWidget {
	final FetchResponse _response;
	StackPage(this._response);

	@override
	Widget build(BuildContext context) {
		final response = _response;

		if (response.success) return TabBarView(children: [
			NumList('bus'),
			NumList('tram'),
			NumList('trol'),
			NumList('minibus'),
			NumList('expressbus'),
			NumList('nightbus'),
		]);

		Container createLine(String str) => Container(child: Text(str), margin: EdgeInsets.only(bottom: 10));

		List<Widget> errorLines = [
			createLine('ERROR'),
			(response.error ?? '').isNotEmpty ? createLine(response.error) : null,
			RaisedButton(child: Text('Try again'), onPressed: () => timetableState.rebuild()),
		]..removeWhere((widget) => widget == null);

		return Center(child: IntrinsicHeight(child: Column(children: errorLines)));
	}
}


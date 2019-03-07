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
	bool searching = false;

	List<Stop> searchResults = [];

	void rebuild() {
		setState(() => update = !update);
	}

	Widget showRoutes() {
		timetableState = this;
		return stops.keys.length == 0 ? FutureBuilder<FetchResponse>(
			future: fetchData(),
			builder: (_, snapshot) {
				if (snapshot.connectionState == ConnectionState.done) return StackPage(snapshot.data);
				return Center(child: CircularProgressIndicator());
			},
		) : StackPage(FetchResponse(true));
	}

	String joinStopInfo(Stop stop) {
		return [stop.city, stop.area, stop.street].where((a) => a != null && a.isNotEmpty).join(', ');
	}

	Widget showResults() {
		return Container(
			child: ListView.builder(
				itemCount: searchResults.length,
				itemBuilder: (context, i) {
					final Stop stop = searchResults[i];
					return ListTile(
						title: Text(stop.name, style: TextStyle(fontSize: 18)),
						subtitle: Text(joinStopInfo(stop), style: TextStyle(fontSize: 12)),
						// onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TimePage(_route, stop))),
						onTap: () {
							print(stop.id);
						},
					);
				}
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
			length: 6,
			child: Scaffold(
				appBar: AppBar(
					elevation: Platform.isIOS ? 0 : 4,
					title: searching ? TextField(
						autofocus: true,
						onChanged: (val) => setState(() => searchResults = searchStops(val)),
						decoration: InputDecoration(hintText: 'Search...', border: InputBorder.none),
					) : Text('Timetable'),
					bottom: TabBar(tabs: [
						Tab(icon: Icon(Icons.directions_bus, color: colors['bus'])),
						Tab(icon: Icon(Icons.tram, color: colors['tram'])),
						Tab(icon: Icon(Icons.directions_bus, color: colors['trol'])),
						Tab(icon: Icon(Icons.directions_bus, color: colors['minibus'])),
						Tab(icon: Icon(Icons.directions_bus, color: colors['expressbus'])),
						Tab(icon: Icon(Icons.directions_bus, color: colors['nightbus'])),
					]),
					actions: [
						IconButton(icon: Icon(searching ? Icons.close : Icons.search), onPressed: () {
							setState(() => searching = !searching);
						}),
						IconButton(icon: Icon(Icons.settings), onPressed: () {
							Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
						})
					],
				),
				body: searching ? showResults() : showRoutes(),
			),
		);
	}
}

class TimetablePage extends StatefulWidget {
	@override
	TimetablePageState createState() => TimetablePageState();
}

class StackPage extends StatelessWidget {
	StackPage(this._response);
	final FetchResponse _response;

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


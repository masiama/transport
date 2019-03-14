import 'dart:io';
import 'package:flutter/material.dart';
import 'util.dart';
import 'time.dart';
import 'rs.dart';
import 'data/stop.dart';
import 'data/route.dart';

class SearchTimePage extends StatelessWidget {
	SearchTimePage(this._routes, this._stop);
	final List<RouteType> _routes;
	final Stop _stop;

	List<Widget> timeToWidget(BuildContext context, Map<int, List<int>> times) {
		double max = MediaQuery.of(context).size.width;
		double size = 32.0;

		List<Widget> children = [];
		int oneH = 13;
		int twoH = 25;
		int twoM = 16;

		Widget createText(String text, double size, [bool large = false]) => Container(
			margin: EdgeInsets.only(right: large ? 5.0: 2.0),
			child: Text(text, style: TextStyle(fontSize: size))
		);

		for (int h in times.keys) {
			List<Widget> temp = [];

			double hSize = ((h % 24) < 10 ? oneH : twoH) + 2.0;
			temp.add(createText((h % 24).toString(), 22.0));

			for (int m in times[h]) {
				bool large = m == times[h].last;
				hSize += twoM + (large ? 5.0 : 2.0);
				temp.add(createText(m.toString().padLeft(2, '0'), 14.0, large));
			}

			size += hSize;
			if (size > max) break;

			children += temp;
		}

		return children;
	}

	@override
	Widget build(BuildContext context) {
		Map<String, Stop> stops = {};
		List<String> ids = _stop.id.split(',');
		_routes.forEach((route) {
			stops[route.sortKey] = route.stops.firstWhere((s) => ids.contains(s.id));
		});

		return Scaffold(
			appBar: AppBar(
				elevation: Platform.isIOS ? 0 : 4,
				title: Text(_stop.name),
			),
			body: ListView.separated(
				itemCount: _routes.length * 2,
				separatorBuilder: (context, i) => i % 2 == 1 ? Divider(color: Theme.of(context).textTheme.title.color) : Container(),
				itemBuilder: (context, i) {
					RouteType route = _routes[(i / 2).floor()];
					Stop stop = stops[route.sortKey];

					ListTile createTile(Widget title) => ListTile(
						title: title,
						onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TimePage(route, stop))),
					);

					if (i % 2 == 0) return createTile(Row(children: [
						Container(
							padding: EdgeInsets.all(2.0),
							margin: EdgeInsets.only(right: 10.0),
							color: colors[route.transport],
							child: Center(child: Text(route.number, style: TextStyle(
								color: Theme.of(context).canvasColor,
								fontWeight: FontWeight.w600,
							))),
						),
						Text(route.name)
					]));

					Map<String, Map<int, List<int>>> _times = getTime(route, stop);

					DateTime now = DateTime.now();
					int hour = now.hour;
					int minute = now.minute;

					var weekdays = _times.keys.where((w) => w.indexOf(now.weekday.toString()) > -1);
					if (weekdays.length == 0) return createTile(Text('Does not operate today'));

					String weekday = weekdays.first;
					var hours = _times[weekday].keys;

					if (hour <= hours.first) return createTile(Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: timeToWidget(context, _times[weekday]),
					));

					List<int> minutesL = _times[weekday][hours.last];
					if (hour > hours.last || hour == hours.last && minute > minutesL.last) {
						return createTile(Text('Last departure was at ${hours.last}:${minutesL.last}'));
					}

					Map<int, List<int>> times = {};
					for (int h in hours) {
						if (h > hour) times[h] = _times[weekday][h];
						if (h != hour) continue;

						List<int> temp = [];
						for (int m in _times[weekday][h]) {
							if (m >= minute) temp.add(m);
						}
						if (temp.isNotEmpty) times[h] = temp;
					}

					return createTile(Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: timeToWidget(context, times),
					));
				},
			)
		);
	}
}

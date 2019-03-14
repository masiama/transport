import 'dart:io';
import 'package:flutter/material.dart';
import 'util.dart';
import 'rs.dart';
import 'trip.dart';
import 'data/stop.dart';
import 'data/route.dart';

class _TimePageState extends State<TimePage> with SingleTickerProviderStateMixin {
	_TimePageState(this._route, this._stop);
	final RouteType _route;
	final Stop _stop;

	Map<String, GlobalKey> _keys = {};
	Map<String, ScrollController> _scrollControllers = {};
	TabController _tabController;

	Map<String, Map<int, List<int>>> _times = {};
	Map<String, int> _currentHour = {};
	List<String> _weekdays = [];

	void initState() {
		_times = getTime(_route, _stop);
		_weekdays = _times.keys.toList();
		_weekdays.sort();

		DateTime now = DateTime.now();
		int hour = now.hour;

		String day = now.weekday.toString();
		int selected = 0;
		for (var i = 0; i < _weekdays.length; i++) {
			String weekday = _weekdays[i];

			if (weekday.indexOf(day) > -1) selected = i;

			var hours = _times[weekday].keys;
			if (hour <= hours.first || hour > hours.last) continue;

			int idx = hours.where((h) => h >= hour).first;
			_currentHour[weekday] = idx;

			_keys[weekday] = GlobalKey();
			_keys['${weekday}_0'] = GlobalKey();
			_scrollControllers[weekday] = ScrollController();
		}

		_tabController = TabController(vsync: this, length: _weekdays.length, initialIndex: selected)..addListener(() {
			if (_tabController.indexIsChanging) return;
			updateScroll(_weekdays[_tabController.index]);
		});

		WidgetsBinding.instance.addPostFrameCallback((_) => updateScroll(_weekdays[selected]));
		super.initState();
	}

	void updateScroll(String weekday) {
		GlobalKey key = _keys[weekday];
		GlobalKey key_0 = _keys['${weekday}_0'];
		if (key_0 == null) return;

		RenderBox renderBox = key.currentContext.findRenderObject();
		RenderBox renderBox_0 = key_0.currentContext.findRenderObject();
		Offset position = renderBox.localToGlobal(Offset.zero);
		Offset position_0 = renderBox_0.localToGlobal(Offset.zero);
		_scrollControllers[weekday].animateTo(position.dy - position_0.dy, duration: Duration(microseconds: 1), curve: Curves.linear);
	}

	GlobalKey getKey(String weekday, int hour) {
		if (_keys.containsKey('${weekday}_0')) {
			if (hour == _times[weekday].keys.first) return _keys['${weekday}_0'];
			if (hour == _currentHour[weekday]) return _keys[weekday];
		}
		return null;
	}

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
			length: _times.keys.length,
			child: Scaffold(
				appBar: AppBar(
					elevation: Platform.isIOS ? 0 : 4,
					backgroundColor: colors[_route.transport],
					title: Text(_stop.name),
					bottom: TabBar(
						controller: _tabController,
						tabs: _weekdays.map((weekday) => Tab(text: getTimeTitle(weekday))).toList()
					),
				),
				body: TabBarView(
					controller: _tabController,
					children: _weekdays.map((weekday) {
						int i = -1;
						return ListView(
							controller: _scrollControllers[weekday],
							children: _times[weekday].keys.map((hour) => Container(
								key: getKey(weekday, hour),
								padding: const EdgeInsets.all(10),
								decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.grey[700]))),
								child: Row(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Container(
											child: Text(
												(hour % 24).toString(),
												textAlign: TextAlign.center,
												style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
											),
											margin: const EdgeInsets.only(right: 10),
											width: 25,
										),
										Expanded(child: GridView.extent(
											physics: const NeverScrollableScrollPhysics(),
											shrinkWrap: true,
											maxCrossAxisExtent: 25.0,
											padding: const EdgeInsets.only(right: 10.0),
											mainAxisSpacing: 10.0,
											crossAxisSpacing: 10,
											children: _times[weekday][hour].map((minute) {
												i++;
												return GestureDetector(
													child: Center(child: Text(minute.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 16))),
													onTap: ((i) => () => Navigator.push(
														context,
														MaterialPageRoute(builder: (_) => TripPage(_route, _stop, weekday, i))
													))(i),
												);
											}).toList(),
										)),
									],
								)
							)).toList()
						);
					}).toList()
				),
			),
		);
	}
}

class TimePage extends StatefulWidget {
	TimePage(this._route, this._stop);
	final RouteType _route;
	final Stop _stop;

	@override
	_TimePageState createState() => _TimePageState(_route, _stop);
}

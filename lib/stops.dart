import 'dart:io';
import 'package:flutter/material.dart';
import 'data/route.dart';
import 'data/stop.dart';
import 'util.dart';
import 'time.dart';

class _StopsPageState extends State<StopsPage> {
  _StopsPageState(this._route);
  RouteType _route;

  @override
  Widget build(BuildContext context) {
    final Map<String, RouteType> similarRoutes = Map.from(routes)..removeWhere((k, _) {
      return !k.contains(RegExp('^${_route.number};${_route.transport}'));
    });
    final String oppositeRoute = _route.getKeyForType(_route.type.split('-').reversed.join('-'));
    final List<Stop> stops = _route.stops;
    final bool openModel = similarRoutes.length > (routes.containsKey(oppositeRoute) ? 2 : 1);
    return Scaffold(
      appBar: AppBar(
        elevation: Platform.isIOS ? 0 : 4,
        backgroundColor: colors[_route.transport],
        title: openModel ? GestureDetector(child: Text(_route.name), onTap: () {
          showModalBottomSheet(context: context, builder: (c) => ListView(children: similarRoutes.values.map((route) => ListTile(
            title: Text(route.name),
            onTap: () {
              setState(() => _route = routes[_route.getKeyForType(route.type)]);
              Navigator.pop(c);
            },
          )).toList()));
        }) : Text(_route.name),
        actions: routes.containsKey(oppositeRoute) ? [IconButton(
          icon: const Icon(Icons.swap_vert),
          onPressed: () => setState(() => _route = routes[oppositeRoute]),
        )] : [],
      ),
      body: Container(child: ListView.builder(
        itemCount: stops.length,
        itemBuilder: (context, i) {
          final Stop stop = stops[i];
          return ListTile(
            title: Text(stop.name, style: const TextStyle(fontSize: 18)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TimePage(_route, stop))),
          );
        },
      )),
    );
  }
}

class StopsPage extends StatefulWidget {
  StopsPage(this._route);
  final RouteType _route;

  @override
  _StopsPageState createState() => _StopsPageState(_route);
}

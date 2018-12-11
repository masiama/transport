import 'dart:io';
import 'package:flutter/material.dart';
import 'rs.dart';
import 'util.dart';
import 'data/stop.dart';
import 'data/route.dart';

class TripPage extends StatelessWidget {
  TripPage(this._route, this._stop, this._weekdays, this._index);
  final RouteType _route;
  final String _weekdays;
  final Stop _stop;
  final int _index;
  
  @override
  Widget build(BuildContext context) {
    final times = getTrip(_route, _weekdays, _index);
    return Scaffold(
      appBar: AppBar(
        elevation: Platform.isIOS ? 0 : 4,
        backgroundColor: colors[_route.transport],
      ),
      body: Container(child: ListView.builder(
        itemCount: _route.stops.length,
        itemBuilder: (_, i) {
          final Stop stop = _route.stops[i];
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.grey[700]))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    times[stop.id],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  margin: const EdgeInsets.only(right: 10),
                  width: 70,
                ),
                Expanded(child: Container(child: Text(stop.name, style: TextStyle(
                  fontSize: 20,
                  fontWeight: stop.id == _stop.id ? FontWeight.w600 : FontWeight.normal,
                )))),
              ]
            )
          );
        }
      )),
    );
  }
}

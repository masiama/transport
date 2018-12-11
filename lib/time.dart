import 'dart:io';
import 'package:flutter/material.dart';
import 'util.dart';
import 'rs.dart';
import 'trip.dart';
import 'data/stop.dart';
import 'data/route.dart';

class TimePage extends StatelessWidget {
  TimePage(this._route, this._stop);
  final RouteType _route;
  final Stop _stop;
  
  @override
  Widget build(BuildContext context) {
    final times = getTime(_route, _stop);
    List<String> keys = times.keys.toList();
    keys.sort();
    return DefaultTabController(
      length: times.keys.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: Platform.isIOS ? 0 : 4,
          backgroundColor: colors[_route.transport],
          title: Text(_stop.name),
          bottom: TabBar(tabs: keys.map((time) => Tab(text: getTimeTitle(time))).toList()),
        ),
        body: TabBarView(children: keys.map((key) {
          int i = -1;
          return ListView(children: times[key].keys.map((h) => Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.grey[700]))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    h,
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
                  children: times[key][h].map((m) {
                    i++;
                    return GestureDetector(
                      child: Center(child: Text(m, style: const TextStyle(fontSize: 16))),
                      onTap: ((i) => () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TripPage(_route, _stop, key, i))
                      ))(i),
                    );
                  }).toList(),
                )),
              ],
            )
          )).toList());
        }).toList()),
      ),
    );
  }
}

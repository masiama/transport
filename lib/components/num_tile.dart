import 'package:flutter/material.dart';
import '../auto_size_text.dart';
import '../data/route.dart';
import '../util.dart';
import '../stops.dart';

class Tile extends StatelessWidget {
  Tile(this._route);
  final RouteType _route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StopsPage(_route))),
      child: Container(
        color: colors[_route.transport],
        child: Center(child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: AutoSizeText(_route.number, style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
            color: Theme.of(context).primaryColor
          ))
        )),
      ),
    );
  }
}

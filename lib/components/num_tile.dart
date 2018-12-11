import 'package:flutter/material.dart';
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
				child: Center(child: Text(_route.number, style: TextStyle(
					fontSize: 30,
					color: Theme.of(context).canvasColor,
					fontWeight: FontWeight.w600,
				))),
			)
		);
	}
}

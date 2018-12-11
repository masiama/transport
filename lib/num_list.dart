import 'package:flutter/material.dart';
import 'components/num_tile.dart';
import 'data/route.dart';
import 'rs.dart';

class NumList extends StatelessWidget {
	NumList(this._transport);
	final String _transport;

	@override
	Widget build(BuildContext context) {
		final List<RouteType> routes = filterRoutes(_transport);
		return GridView.extent(
			maxCrossAxisExtent: 80.0,
			padding: const EdgeInsets.all(5.0),
			mainAxisSpacing: 5.0,
			crossAxisSpacing: 5.0,
			children: routes.map((r) => Tile(r)).toList(),
		);
	}
}

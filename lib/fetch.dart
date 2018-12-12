import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'util.dart';
import 'http_date.dart';
import 'data/stop.dart';
import 'data/route.dart';

class FetchResponse {
	String error;
	bool success;

	FetchResponse(this.success, [this.error]);
}

const stopLinks = [
	'https://saraksti.rigassatiksme.lv/riga/stops.txt',
	'http://www.marsruti.lv/rigasmikroautobusi/bbus/stops.txt',
];
const routesLinks = [
	'https://saraksti.rigassatiksme.lv/riga/routes.txt',
	'http://www.marsruti.lv/rigasmikroautobusi/bbus/routes.txt',
];

String dir;

Future<Uint8List> combineLinks(List<String> links) async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	List<int> bytes = [];
	for (var i = 0; i < links.length; i++) {
		final link = links[i];
		final response = await http.get(link);
		await prefs.setString(link, DateTime.now().toString());

		final str = utf8.decode(response.bodyBytes);
		List<String> splt = str.split('\n');
		if (i > 0) splt = splt.getRange(1, splt.length).toList();
		bytes.addAll(utf8.encode(splt.join('\n')));
	}
	return Uint8List.fromList(bytes);
}

Future<void> uploadRoutes() async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	List<String> lines = [], newLines = [];
	for (var i = 0; i < routesLinks.length; i++) {
		final link = routesLinks[i];
		final response = await http.get(link);
		await prefs.setString(link, DateTime.now().toString());

		final str = utf8.decode(response.bodyBytes);
		List<String> splt = str.split('\n');
		if (i > 0) splt = splt.getRange(1, splt.length).toList();
		lines.addAll(splt);
	}

	newLines.add('RouteNum;Transport;RouteType;RouteName;RouteStops');
	final fields = lines[0].toUpperCase().split(';'), fld = {};
	for (var i = 0; i < fields.length; i++) fld[fields[i].trim()] = i;

	String authority;
	for (var i = 1; i < lines.length; i++) {
		final String line = lines[i];
		final List<String> parts = line.split(';');

		if (parts.length <= 1) { newLines.add(line); continue; }

		String getPart(String id) => parts[fld[id]];
		if (parts[fld['AUTHORITY']].isNotEmpty) authority = parts[fld['AUTHORITY']];
		if (authority == 'SpecialDates') continue;

		newLines.add('${getPart('ROUTENUM')};${getPart('TRANSPORT')};${getPart('ROUTETYPE')};${getPart('ROUTENAME')};${getPart('ROUTESTOPS')}');
	}

	await File('$dir/routes.txt').writeAsBytes(utf8.encode(newLines.join('\n')));
}

Future<void> updateFiles() async {
	final stopsBytes = await combineLinks(stopLinks);
	final File sfile = File('$dir/stops.txt');
	await sfile.writeAsBytes(stopsBytes);

	await uploadRoutes();
}

Future<bool> isFirstRun() async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	return prefs.getBool('first') ?? true;
}

Future<void> removeData() async {
	File sfile = File('$dir/stops.txt');
	File rfile = File('$dir/routes.txt');
	if (await sfile.exists()) await sfile.delete();
	if (await rfile.exists()) await rfile.delete();

	final SharedPreferences prefs = await SharedPreferences.getInstance();
	for (var key in prefs.getKeys()) prefs.remove(key);
}

Future<FetchResponse> fetchData() async {
	dir = (await getApplicationDocumentsDirectory()).path;
	final SharedPreferences prefs = await SharedPreferences.getInstance();

	final bool connected = await isConnected();
	final bool first = await isFirstRun();
	if (first) {
		if (!connected) return FetchResponse(false, 'Check your internet connection');

		await updateFiles();
		await prefs.setBool('first', false);
	}

	await parseFiles();
	return FetchResponse(true);
}

Future<void> parseFiles() async {
	loadStops(await File('$dir/stops.txt').readAsString());
	loadRoutes(await File('$dir/routes.txt').readAsString());
}

Future<bool> toUpdate() async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	final List<http.Response> responses = await Future.wait((stopLinks + routesLinks).map((link) => http.head(link)));

	for (var res in responses) {
		final str = prefs.getString(res.request.url.toString()) ?? '';
		final newlm = parseHttpDate(res.headers['last-modified']);

		if (str.isEmpty || newlm.difference(DateTime.parse(str)).inSeconds > 0) return true;
	}

	return false;
}
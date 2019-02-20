import '../util.dart';

Map<String, Stop> stops = {};
Map<String, List<String>> searchCache = {};

Map<String, String> accentMap = {
	'\u{0105}': 'a',
	'\u{00E4}': 'a',
	'\u{0101}': 'a',
	'\u{010D}': 'c',
	'\u{0119}': 'e',
	'\u{0117}': 'e',
	'\u{012F}': 'i',
	'\u{0173}': 'u',
	'\u{016B}': 'u',
	'\u{00FC}': 'u',
	'\u{017E}': 'z',
	'\u{0113}': 'e',
	'\u{0123}': 'g',
	'\u{012B}': 'i',
	'\u{0137}': 'k',
	'\u{013C}': 'l',
	'\u{0146}': 'n',
	'\u{00F6}': 'o',
	'\u{00F5}': 'o',
	'\u{0161}': 's',
	'\u{2013}': '-',
	'\u{2014}': '-',
	'\u{0336}': '-',
	'\u{00ad}': '-',
	'\u{02d7}': '-',
	'\u{201c}': '',
	'\u{201d}': '',
	'\u{201e}': '',
	"'": '',
	'"': ''
};

String toAscii(String str) {
	List<String> arr = str.toLowerCase().split('');

	for (var i = arr.length; --i >= 0;) {
		var ascii = accentMap[arr[i]];
		if (ascii != null) arr[i] = ascii;
	}

	return arr.join('');
}

class Stop {
	String id;
	String name;
	String asciiName;
	List<String> routes = [];

	String getValue(List<String> lineItems, int index) {
		return lineItems.length > index ? lineItems[index].trim() : '';
	}

	void loadValues(List<String> lineItems, Stop prevStop) {
		this.id = lineItems[0];

		String name = getValue(lineItems, 4);
		if (name.isEmpty && prevStop != null) {
			name = prevStop.name;
			asciiName = prevStop.asciiName;
			searchCache[prevStop.asciiName] = searchCache[prevStop.asciiName] ?? [];
			searchCache[prevStop.asciiName].add(id);
		}
		else {
			asciiName = toAscii(name);
			searchCache[asciiName] = searchCache[asciiName] ?? [];
			searchCache[asciiName].add(id);
		}
		this.name = name;
	}
}

void loadStops(String text) {
	Stop prevStop;
	final List<String> lines = text.split('\n');
	for (var i = 1; i < lines.length - 1; i++) {
		final Stop stop = Stop();
		stop.loadValues(lines[i].split(';'), prevStop);
		if (stop.name.isNotEmpty) stops[stop.id] = stop;
		prevStop = stop;
	}
}

List<Stop> searchStops(String text) {
	if (text.isEmpty) return [];

	String l = text.toLowerCase();
	List<String> result = searchCache.keys.where((s) => s.indexOf(l) > -1).toList();

	result.sort((a, b) {
		int diff = a.indexOf(l) - b.indexOf(l);
		return diff == 0 ? compare(a, b) : diff;
	});

	return result.map((name) => stops[searchCache[name][0]]).toList();
}

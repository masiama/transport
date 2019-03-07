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

	String info = '';
	String street = '';
	String area = '';
	String city = '';

	List<String> routes = [];

	String getValue(List<String> lineItems, int index) {
		return lineItems.length > index ? lineItems[index].trim() : '';
	}

	String or(String s1, String s2) {
		return s1.isNotEmpty ? s1 : s2;
	}

	Stop clone() {
		Stop stop = Stop();

		stop.id = this.id;
		stop.name = this.name;
		stop.asciiName = this.asciiName;
		stop.info = this.info;
		stop.street = this.street;
		stop.area = this.area;
		stop.city = this.city;
		stop.routes = this.routes;

		return stop;
	}

	void loadValues(List<String> lineItems, Stop prevStop) {
		this.id = lineItems[0];

		String info = getValue(lineItems, 5);
		if (info.isNotEmpty || prevStop != null) this.info = or(info, prevStop.info);
		String street = getValue(lineItems, 6);
		if (street.isNotEmpty || prevStop != null) this.street = or(street, prevStop.street);
		String area = getValue(lineItems, 7);
		if (area.isNotEmpty || prevStop != null) this.area = or(area, prevStop.area);
		String city = getValue(lineItems, 8);
		if (city.isNotEmpty || prevStop != null) this.city = or(city, prevStop.city);

		String name = getValue(lineItems, 4);
		if (name.isEmpty && prevStop != null) {
			name = prevStop.name;
			this.asciiName = prevStop.asciiName;
		}
		else this.asciiName = toAscii(name);

		searchCache[this.asciiName] = searchCache[this.asciiName] ?? [];
		searchCache[this.asciiName].add(id);

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
	if (text.length < 2) return [];
	final String separators = '–—̶­˗“”„ _-.()\'"';

	String textAscii = toAscii(text);
	String textAsciiW = textAscii.replaceAll(new RegExp(r'\W'), '');
	String textLower = text.toLowerCase().replaceAll(new RegExp(r'\W'), '');

	List<Stop> result = [];

	for (var asciiName in searchCache.keys) {
		int indexOf = asciiName.indexOf(textAscii);
		if (indexOf == -1 || indexOf != 0 && separators.indexOf(asciiName[indexOf - 1]) < 0) continue;

		List<String> ids = searchCache[asciiName];

		for (var id in ids) {
			Stop stop = stops[id];
			if (stop == null) continue;
			if (textAsciiW != textLower) continue;
			if (stop.name.toLowerCase().replaceAll(new RegExp(r'\W'), '').indexOf(textLower) == -1) continue;

			result.add(stop.clone());
		}
	}

	List<Stop> unique = [];
	for (var s in result) {
		int idx = unique.indexWhere((u) => u.name == s.name && u.street == s.street);
		if (idx > -1) { unique[idx].id += ',${s.id}'; continue; }
		unique.add(s);
	}
	return unique..sort((a, b) {
		int c = a.name.compareTo(b.name);
		if (c != 0) return c;
		int d = a.area.compareTo(b.area);
		if (d != 0) return d;
		return a.street.compareTo(b.street);
	});
}

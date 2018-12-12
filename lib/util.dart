import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

// TODO: NFC Reader in settings
// TODO: Change theme depending on day
// TODO: Stop search

const Map<String, Color> colors = {
	'bus': Color(0xFFf4B427),
	'tram': Color(0xFFff000C),
	'trol': Color(0xFF009dE0),
	'minibus': Color(0xFF7F237E),
	'expressbus': Color(0xFFf6882E),
	'nightbus': Color(0xFFBBBBBB),
};

bool isDigit(String s) {
	try { return double.parse(s) != null; }
	catch (_) { return false; }
}

int compare(String a, String b) {
	int comparei(int x, int y) => (x < y) ? -1 : ((x == y) ? 0 : 1);
	int len1 = a.length, len2 = b.length;
	int idx1 = 0, idx2 = 0;

	while (idx1 < len1 && idx2 < len2) {
		String c1 = a[idx1++];
		String c2 = b[idx2++];

		bool isDigit1 = isDigit(c1);
		bool isDigit2 = isDigit(c2);

		if (isDigit1 && !isDigit2) return -1;
		if (!isDigit1 && isDigit2) return 1;
		if (!isDigit1 && !isDigit2) {
			int c = c1.compareTo(c2);
			if (c != 0) return c;
		} else {
			int num1 = num.parse(c1);
			while (idx1 < len1) {
				String digit = a[idx1++];
				if (isDigit(digit)) num1 = num1 * 10 + num.parse(digit);
				else {
					idx1--;
					break;
				}
			}

			int num2 = num.parse(c2);
			while (idx2 < len2) {
				String digit = b[idx2++];
				if (isDigit(digit)) num2 = num2 * 10 + num.parse(digit);
				else {
					idx2--;
					break;
				}
			}

			if (num1 != num2) return comparei(num1, num2);
		}
	}

	if (idx1 < len1) return 1;
	if (idx2 < len2) return -1;
	return 0;
}

String getTimeTitle(String weekdays) {
	if (weekdays == '12345') return 'Working days';
	if (weekdays == '1234') return 'Monday - Thursday';
	if (weekdays == '2345') return 'Tuesday - Friday';
	if (weekdays == '123456') return 'Monday - Saturday';
	if (weekdays == '67') return 'Weekend';
	if (weekdays == '5') return 'Friday';
	if (weekdays == '6') return 'Saturday';
	if (weekdays == '7') return 'Sunday';
	if (weekdays == '1') return 'Monday';
	return 'all_days';
}

Future<bool> isConnected() async {
	return await Connectivity().checkConnectivity() != ConnectivityResult.none;
}

Future<void> saveTheme(String theme) async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	await prefs.setString('theme', theme);
}

Future<String> getTheme() async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	return prefs.getString('theme') ?? 'light';
}

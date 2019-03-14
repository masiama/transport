import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

const Map<String, Color> colors = {
  'bus': Color(0xFFf4B427),
  'tram': Color(0xFFff000C),
  'trol': Color(0xFF009dE0),
  'minibus': Color(0xFF7F237E),
  'expressbus': Color(0xFFf6882E),
  'nightbus': Color(0xFFBBBBBB),
};

const List<String> _MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

DateTime parseHttpDate(String date) {
  final List<String> array = date.split(' ')..removeAt(0);
  final int day = int.parse(array[0]);
  final int month = _MONTHS.indexOf(array[1]) + 1;
  final int year = int.parse(array[2]);
  final List<int> time = array[3].split(':').map(int.parse).toList();

  return DateTime(year, month, day, time[0], time[1], time[2]);
}

bool isDigit(String s) {
  try {
    return double.parse(s) != null;
  } catch (_) {
    return false;
  }
}

int compare(String a, String b) {
  int comparei(int x, int y) => (x < y) ? -1 : ((x == y) ? 0 : 1);
  final int len1 = a.length, len2 = b.length;
  int idx1 = 0, idx2 = 0;

  while (idx1 < len1 && idx2 < len2) {
    final String c1 = a[idx1++];
    final String c2 = b[idx2++];

    final bool isDigit1 = isDigit(c1);
    final bool isDigit2 = isDigit(c2);

    if (isDigit1 && !isDigit2) return -1;
    if (!isDigit1 && isDigit2) return 1;
    if (!isDigit1 && !isDigit2) {
      final int c = c1.compareTo(c2);
      if (c != 0) return c;
    } else {
      int num1 = int.parse(c1);
      while (idx1 < len1) {
        final String digit = a[idx1++];
        if (isDigit(digit)) num1 = num1 * 10 + int.parse(digit);
        else {
          idx1--;
          break;
        }
      }

      int num2 = int.parse(c2);
      while (idx2 < len2) {
        final String digit = b[idx2++];
        if (isDigit(digit)) num2 = num2 * 10 + int.parse(digit);
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
  if (weekdays == '123456') return 'Monday - Saturday';
  if (weekdays == '67') return 'Weekend';
  if (weekdays == '6') return 'Saturday';
  if (weekdays == '7') return 'Sunday';
  return 'all_days';
}

Future<bool> isConnected() async {
  return await Connectivity().checkConnectivity() != ConnectivityResult.none;
}

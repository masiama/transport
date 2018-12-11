import 'util.dart';
import 'data/route.dart';
import 'data/stop.dart';

List<RouteType> filterRoutes(String stransport, [String snum = '', String stype = '']) {
  List<RouteType> results = [];
  Map<String, RouteType> routesUnique = {};

  for (final route in routes.values) {
    if (stransport.isNotEmpty && stransport != route.transport) continue;
    if (snum.isNotEmpty && snum != route.number) continue;
    if (stype.isNotEmpty && stype != route.type) continue;

    final String transport = route.transport;
    final int order = route.order;
    final String number = route.number;

    final String key = '$number;$transport';
    if (routesUnique.containsKey(key) && snum.isEmpty && order != 1) continue;

    final RouteType r = route;
    r.sortKey = number;

    results.add(r);
    if (stype.isEmpty && key.isNotEmpty) routesUnique[key] = r;
  }
  results.sort((a, b) => compare(a.sortKey, b.sortKey));

  return results;
}

Map<String, Map<String, List<String>>> getTime(RouteType route, Stop stop) {
  final List<StopSchedule> schedules = route.times.where((time) => time.stop.id == stop.id).toList();
  final Map<String, Map<String, List<String>>> sections = {};

  for (final schedule in schedules) {
    sections[schedule.weekdays] = {};
    final List<String> times = schedule.times.split(',');
    for (final t in times) {
      final int time = num.parse(t);
      final String h = (time / 60 % 24).floor().toString();
      final String m = (time % 60).toString().padLeft(2, '0');

      if (sections[schedule.weekdays][h] == null) sections[schedule.weekdays][h] = [];
      sections[schedule.weekdays][h].add(m);
    }
  }

  return sections;
}

Map<String, String> getTrip(RouteType route, String weekdays, int index) {
  final List<StopSchedule> schedules = route.times.where((t) => t.weekdays == weekdays).toList();
  Map<String, String> times = {};

  for (var schedule in schedules) {
    final int time = num.parse(schedule.times.split(',')[index]);
    final int h = (time / 60 % 24).floor();
    final String m = (time % 60).toString().padLeft(2, '0');
    times[schedule.stop.id] = '$h:$m';
  }

  return times;
}

import 'stop.dart';

Map<String, RouteType> routes = {};

class StopSchedule {
  Stop stop;
  String weekdays;
  String times;
}

class RouteType {
  String id;
  int order;
  String transport;
  String number;
  String name;
  String type;
  List<Stop> stops;
  List<StopSchedule> times;

  String sortKey;

  String getKey() {
    return '$number;$transport;$type';
  }

  String getKeyForType(String type) {
    return '$number;$transport;$type';
  }
}

void loadRoutes(String text) {
  final List<String> lines = text.split('\n');

  final fields = lines[0].toUpperCase().split(';'), fld = {};
  for (var i = 0; i < fields.length; i++) fld[fields[i].trim()] = i;

  var order = 0, done = [];
  String number = '', directionName, transport;
  for (var i = 1; i < lines.length; i += 2) {
    final String line = lines[i];
    final List<String> parts = line.split(';');

    ++order;

    if (parts[fld['ROUTENUM']].isNotEmpty) {
      number = parts[fld['ROUTENUM']];
      order = 1;
    }

    if (parts[fld['TRANSPORT']].isNotEmpty) {
      transport = parts[fld['TRANSPORT']];
      order = 1;
    }

    if (number.length == 3) {
      if (number[0] == '3' && transport != 'expressbus') {
        transport = 'expressbus';
        order = 1;
      }
      if (number[0] == '2' && transport != 'minibus') {
        transport = 'minibus';
        order = 1;
      }
    }
    else if (transport == 'expressbus' || transport == 'minibus') {
      transport = 'bus';
    }

    final int idx = done.indexOf(transport);
    if (idx > -1 && transport != done[done.length - 1]) continue;
    if (idx == -1) done.add(transport);

    if (parts[fld['ROUTENAME']].isNotEmpty) directionName = parts[fld['ROUTENAME']];

    final String type = parts[fld['ROUTETYPE']];
    final String key = '$number;$transport;$type';

    if (routes.containsKey(key)) continue;

    List<Stop> rstops = [];
    Stop prevStop;

    for (var sid in parts[fld['ROUTESTOPS']].split(',')) {
      Stop stop = stops[sid];
      if (prevStop != null && prevStop.name == stop.name) continue;
      prevStop = stop;
      stop.routes.add(key);
      rstops.add(stop);
    }

    final RouteType route = RouteType();
    route.transport = transport;
    route.number = number;
    route.name = directionName;
    route.stops = rstops;
    route.type = type;
    route.order = order;
    route.times = explodeTimes(lines[i + 1], rstops);

    routes[key] = route;
  }
}

List<String> getAccumulatedTimes(String times) {
  final List<String> array = times.split(',');
  List<String> result = List<String>(array.length);
  int sum = 0;
  for (int i = 0; i < array.length; i++) {
    sum += num.parse(array[i]);
    result[i] = sum.toString();
  }
  return result;
}

List<StopSchedule> explodeTimes(String timesString, List<Stop> stops) {
  List<StopSchedule> list = [];
  List<String> workdays = [];
  List<String> asdasd = [];
  final timesArray = timesString.split(',,');
  final times = getAccumulatedTimes(timesArray[0]);
  final weekdayMetadata = timesArray[3].split(',');
  for (var m = 0; m < stops.length; m++) {
    var stop = stops[m];
    var timesStartIndex = 0;
    var correctionItems = timesArray[m + 3].split(',');
    var timeCorrection = m > 0 ? num.parse(correctionItems[0]) : 0;
    var countLimit = (m <= 0 || correctionItems.length <= 1) ? 1000 : num.parse(correctionItems[1]);
    var correctionIndex = 1;
    var count = 0;
    var i = 0;
    while (i < weekdayMetadata.length) {
      var timesEndIndex;
      var weekdays = weekdayMetadata[i];
      timesEndIndex = i + 1 >= weekdayMetadata.length ? times.length : num.parse(weekdayMetadata[i + 1]);
      var timesValue = '';
      for (int k = timesStartIndex; k < timesEndIndex; k++) {
        if (k != timesStartIndex) timesValue += ',';
        count++;
        if (count > countLimit) {
          correctionIndex++;
          timeCorrection += num.parse(correctionItems[correctionIndex]) - 5;
          if (correctionIndex + 1 < correctionItems.length) {
            correctionIndex++;
            countLimit = num.parse(correctionItems[correctionIndex]);
          }
          else countLimit = 1000;
          count = 1;
        }
        int newTime = num.parse(times[k]) + timeCorrection;
        timesValue += newTime.toString();
        times[k] = newTime.toString();
      }
      if (timesValue.isNotEmpty) {
        workdays.add(weekdays);
        asdasd.add(timesValue.toString());
        final s = StopSchedule();
        s.stop = stop;
        s.weekdays = weekdays;
        s.times = timesValue.toString();
        list.add(s);
      }
      timesStartIndex = timesEndIndex;
      i += 2;
      if (i >= weekdayMetadata.length) break;
    }
  }

  return list;
}

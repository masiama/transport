Map<String, Stop> stops = {};

class Stop {
  String id;
  String name;
  List<String> routes = [];
  
  String getValue(List<String> lineItems, int index) {
      return lineItems.length > index ? lineItems[index].trim() : '';
  }
  
  void loadValues(List<String> lineItems, Stop prevStop) {
    this.id = lineItems[0];
    
    String name = getValue(lineItems, 4);
    if (name.isEmpty && prevStop != null) name = prevStop.name;
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

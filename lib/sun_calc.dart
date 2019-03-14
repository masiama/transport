import 'dart:math';

const int msPerDay = 1000 * 60 * 60 * 24;
const double julian1970 = 2440588.0;
const double julian2000 = 2451545.0;
const double rad = pi / 180;
final DateTime sept28Date = DateTime.utc(2017, DateTime.september, 28, 12);
const double sept28Obliquity = 23.43697;
const double obliquityShift = 2.4 / (365.2422 * 40000 * 24);
const double siderealZero = 280.1470;
const double deltaSidereal = 360.9856235;
const double meanAnomalyZero = 357.5291;
const double deltaMeanAnomaly = 0.98560028;
const double planetocentricPerihelion = rad * 102.9372;
const List<double> sunTransit = const [0.0009, 0.0053, -0.0068, 1.0000000];

class SunCalc {
  static const _times = const [
    const [-0.833 * rad, 'sunrise', 'sunset'],
    const [-0.3 * rad, 'sunriseEnd', 'sunsetStart'],
    const [-6 * rad, 'dawn', 'dusk'],
    const [-12 * rad, 'nauticalDawn', 'nauticalDusk'],
    const [-18 * rad, 'nightEnd', 'night'],
    const [6 * rad, 'goldenHourEnd', 'goldenHour'],
  ];

  final DateTime date;
  final num _longitude;
  final num _latitude;

  Map<String, double> eclipticCoords;
  Map<String, DateTime> times;

  num get longitude => -1 * _longitude * rad;
  num get latitude => _latitude * rad;
  num get julian => dateToJulian(date);
  num get daysSince2000 => julian - julian2000;
  num get obliquity => trueObliquity(date);
  num get siderealTime => rad * (siderealZero + deltaSidereal * daysSince2000) - longitude;

  SunCalc(this.date, this._longitude, this._latitude) {
    eclipticCoords = {
      'lat': 0.0,
      'lng': eclipticLongitude(),
    };
    times = getTimes();
  }

  double eclipticLongitude({num days}) {
    final double mA = meanAnomaly(days ?? daysSince2000);
    final double center = rad * (1.9148 * sin(mA) + 0.02 * sin(2 * mA) + 0.0003 * sin(3 * mA));
    return mA + center + planetocentricPerihelion + pi;
  }

  Map<String, DateTime> getTimes() {
    final int julianCycle = (daysSince2000 - sunTransit[0] - longitude / (2 * pi)).round();
    final double noonTransit = approxTransit(0, longitude, julianCycle);
    final double mA = meanAnomaly(noonTransit);
    final double eclipticLng = eclipticLongitude(days: noonTransit);
    final double dec = declination(lng: eclipticLng);

    final double jNoon = transitJulian(noonTransit, mA, eclipticLng);

    final Map<String, DateTime> solarTimes = {
      'noon': dateFromJulian(jNoon),
      'nadir': dateFromJulian(jNoon - 0.5),
    };

    _times.forEach((time) {
      final double jSet = getSetJulian(time[0], longitude, latitude, dec, julianCycle, mA, eclipticLng);
      final double jRise = 2 * jNoon - jSet;
      solarTimes[time[1]] = dateFromJulian(jRise);
      solarTimes[time[2]] = dateFromJulian(jSet);
    });

    return solarTimes;
  }

  static double meanAnomaly(num days) {
    return rad * (meanAnomalyZero + deltaMeanAnomaly * days);
  }

  double declination({double lng, double lat}) {
    if (lng == null) lng = eclipticCoords['lng'];
    if (lat == null) lat = eclipticCoords['lat'];
    return asin((sin(lat) * cos(obliquity)) + (cos(lat) * sin(obliquity) * sin(lng)));
  }

  static num dateToJulian(DateTime date) {
    return date.millisecondsSinceEpoch / msPerDay - 0.5 + julian1970;
  }

  static DateTime dateFromJulian(double julian) {
    return DateTime.fromMillisecondsSinceEpoch(((julian + 0.5 - julian1970) * msPerDay).floor());
  }

  static double trueObliquity(DateTime date) {
    final int hoursPassed = date.toUtc().difference(sept28Date).inHours;
    return rad * (sept28Obliquity - (hoursPassed * obliquityShift));
  }

  static double approxTransit(num hAngle, double longitude, int julianCycle) {
    return sunTransit[0] + (hAngle + longitude) / (2 * pi) + julianCycle;
  }

  static double transitJulian(double transit, double mA, double eclipticLng) {
    return julian2000 + transit + sunTransit[1] * sin(mA) + sunTransit[2] * sin(2 * eclipticLng);
  }

  static double getSetJulian(
    double altitude,
    double longitude,
    double latitude,
    double declination,
    int julianCycle,
    double mA,
    double eclipticLng
  ) {
    final double hAngle = acos((sin(altitude) - sin(latitude) * sin(declination)) / (cos(latitude) * cos(declination)));
    final double setTransit = approxTransit(hAngle, longitude, julianCycle);
    return transitJulian(setTransit, mA, eclipticLng);
  }
}

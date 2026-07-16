import 'package:adhan/adhan.dart';
void main() {
  final coords = Coordinates(34.0331, -5.0003);
  final now = DateTime.now();
  final date = DateComponents(now.year, now.month, now.day);
  final params = CalculationMethod.muslim_world_league.getParameters();
  params.madhab = Madhab.shafi;
  final pt = PrayerTimes(coords, date, params);
  print('Fajr: ${pt.fajr}');
  print('Dhuhr: ${pt.dhuhr}');
  print('Maghrib: ${pt.maghrib}');
  print('SUCCESS');
}

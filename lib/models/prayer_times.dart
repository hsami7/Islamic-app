import 'package:hive/hive.dart';

part 'prayer_times.g.dart';

@HiveType(typeId: 2)
class PrayerTimes extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String fajr;

  @HiveField(2)
  final String sunrise;

  @HiveField(3)
  final String dhuhr;

  @HiveField(4)
  final String asr;

  @HiveField(5)
  final String maghrib;

  @HiveField(6)
  final String isha;

  @HiveField(7)
  final String imsak;

  @HiveField(8)
  final String midnight;

  @HiveField(9)
  final String firstThird;

  @HiveField(10)
  final String lastThird;

  @HiveField(11)
  final String method;

  @HiveField(12)
  final String school;

  @HiveField(13)
  final double latitude;

  @HiveField(14)
  final double longitude;

  @HiveField(15)
  final String timezone;

  @HiveField(16)
  final HijriDate hijriDate;

  PrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
    required this.firstThird,
    required this.lastThird,
    required this.method,
    required this.school,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.hijriDate,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json, {double lat = 0, double lng = 0, String tz = ''}) {
    final timings = json['timings'] ?? {};
    final readableDate = json['date']?['readable'] as String?;
    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      try {
        return DateTime.parse(dateStr);
      } on FormatException {
        // Handle format like "15 Jun 2025"
        final parts = dateStr.split(' ');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final monthStr = parts[1];
          final year = int.parse(parts[2]);
          final months = {
            'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
            'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
          };
          return DateTime(year, months[monthStr] ?? 1, day);
        }
        return DateTime.now();
      }
    }

    return PrayerTimes(
      date: parseDate(readableDate),
      fajr: timings['Fajr'] ?? '',
      sunrise: timings['Sunrise'] ?? '',
      dhuhr: timings['Dhuhr'] ?? '',
      asr: timings['Asr'] ?? '',
      maghrib: timings['Maghrib'] ?? '',
      isha: timings['Isha'] ?? '',
      imsak: timings['Imsak'] ?? '',
      midnight: timings['Midnight'] ?? '',
      firstThird: timings['Firstthird'] ?? '',
      lastThird: timings['Lastthird'] ?? '',
      method: json['meta']?['method']?['name'] ?? '',
      school: json['meta']?['method']?['params']?['school']?.toString() ?? '',
      latitude: lat,
      longitude: lng,
      timezone: tz,
      hijriDate: HijriDate.fromJson(json['date']?['hijri'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'imsak': imsak,
      'midnight': midnight,
      'firstThird': firstThird,
      'lastThird': lastThird,
      'method': method,
      'school': school,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'hijriDate': hijriDate.toJson(),
    };
  }

  List<PrayerTime> get prayers => [
    PrayerTime(name: 'Fajr', time: fajr, arabicName: 'الفجر', icon: 'assets/icons/fajr.svg'),
    PrayerTime(name: 'Sunrise', time: sunrise, arabicName: 'الشروق', icon: 'assets/icons/sunrise.svg'),
    PrayerTime(name: 'Dhuhr', time: dhuhr, arabicName: 'الظهر', icon: 'assets/icons/dhuhr.svg'),
    PrayerTime(name: 'Asr', time: asr, arabicName: 'العصر', icon: 'assets/icons/asr.svg'),
    PrayerTime(name: 'Maghrib', time: maghrib, arabicName: 'المغرب', icon: 'assets/icons/maghrib.svg'),
    PrayerTime(name: 'Isha', time: isha, arabicName: 'العشاء', icon: 'assets/icons/isha.svg'),
  ];

  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    for (final prayer in prayers) {
      final prayerTime = _parseTime(prayer.time);
      if (prayerTime.isAfter(now)) {
        return prayer;
      }
    }
    // If all prayers passed, return Fajr of next day
    return prayers.first;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  @override
  String toString() => 'PrayerTimes(date: $date, fajr: $fajr, isha: $isha)';
}

class PrayerTime {
  final String name;
  final String time;
  final String arabicName;
  final String icon;

  PrayerTime({
    required this.name,
    required this.time,
    required this.arabicName,
    required this.icon,
  });

  bool get isFard => name != 'Sunrise';
}

class HijriDate {
  final String day;

  final String month;

  final String year;

  final String monthNumber;

  final String weekday;

  final String weekdayArabic;

  HijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthNumber,
    required this.weekday,
    required this.weekdayArabic,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      day: json['day'] ?? '',
      month: json['month']?['en'] ?? '',
      year: json['year']?.toString() ?? '',
      monthNumber: json['month']?['number']?.toString() ?? '',
      weekday: json['weekday']?['en'] ?? '',
      weekdayArabic: json['weekday']?['ar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'month': month,
      'year': year,
      'monthNumber': monthNumber,
      'weekday': weekday,
      'weekdayArabic': weekdayArabic,
    };
  }

  String get formatted => '$day $month $year';
  String get formattedArabic => '$day $month $yearهـ';
}
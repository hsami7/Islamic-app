import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/models/prayer_times.dart';

void main() {
  // ─── Sample Aladhan API JSON ───────────────────────────────────────────
  final Map<String, dynamic> sampleAladhanJson = {
    'date': {
      'readable': '15 Jun 2025',
      'hijri': {
        'day': '18',
        'month': {'en': 'Dhuʻl-Hijjah', 'number': 12},
        'year': '1446',
        'weekday': {'en': 'Sunday', 'ar': 'الاحد'},
      },
    },
    'timings': {
      'Fajr': '04:15 (UTC)',
      'Sunrise': '05:45 (UTC)',
      'Dhuhr': '12:30 (UTC)',
      'Asr': '16:00 (UTC)',
      'Maghrib': '18:45 (UTC)',
      'Isha': '20:15 (UTC)',
      'Imsak': '04:05 (UTC)',
      'Midnight': '00:30 (UTC)',
      'Firstthird': '22:30 (UTC)',
      'Lastthird': '02:30 (UTC)',
    },
    'meta': {
      'method': {'name': 'Muslim World League'},
      'latitude': 34.0331,
      'longitude': -5.0003,
      'timezone': 'Africa/Casablanca',
    },
  };

  group('PrayerTimes model parsing from Aladhan API JSON', () {
    test('parses all timing fields correctly', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson,
          lat: 34.0331, lng: -5.0003, tz: 'Africa/Casablanca');

      expect(pt.fajr, equals('04:15 (UTC)'));
      expect(pt.sunrise, equals('05:45 (UTC)'));
      expect(pt.dhuhr, equals('12:30 (UTC)'));
      expect(pt.asr, equals('16:00 (UTC)'));
      expect(pt.maghrib, equals('18:45 (UTC)'));
      expect(pt.isha, equals('20:15 (UTC)'));
      expect(pt.imsak, equals('04:05 (UTC)'));
      expect(pt.midnight, equals('00:30 (UTC)'));
      expect(pt.firstThird, equals('22:30 (UTC)'));
      expect(pt.lastThird, equals('02:30 (UTC)'));
    });

    test('parses meta fields (method, school)', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson);
      expect(pt.method, equals('Muslim World League'));
    });

    test('stores latitude, longitude, timezone from params', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson,
          lat: 34.0331, lng: -5.0003, tz: 'Africa/Casablanca');

      expect(pt.latitude, equals(34.0331));
      expect(pt.longitude, equals(-5.0003));
      expect(pt.timezone, equals('Africa/Casablanca'));
    });

    test('handles missing timings with empty strings', () {
      final json = {
        'date': {'readable': '15 Jun 2025'},
        'timings': {},
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);

      expect(pt.fajr, equals(''));
      expect(pt.sunrise, equals(''));
      expect(pt.dhuhr, equals(''));
      expect(pt.asr, equals(''));
      expect(pt.maghrib, equals(''));
      expect(pt.isha, equals(''));
    });

    test('handles missing date with current date fallback', () {
      final json = <String, dynamic>{
        'timings': {'Fajr': '04:15'},
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      // Should not throw; date defaults to DateTime.now()
      expect(pt.date, isA<DateTime>());
    });

    test('handles missing meta method name', () {
      final json = {
        'date': {'readable': '15 Jun 2025'},
        'timings': {},
        'meta': {'method': {}},
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.method, equals(''));
    });

    test('handles missing school param', () {
      final json = {
        'date': {'readable': '15 Jun 2025'},
        'timings': {},
        'meta': {'method': {'params': {}}},
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.school, equals(''));
    });

    test('toJson round-trip preserves data', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson,
          lat: 34.0331, lng: -5.0003, tz: 'Africa/Casablanca');
      final json = pt.toJson();

      expect(json['fajr'], equals('04:15 (UTC)'));
      expect(json['isha'], equals('20:15 (UTC)'));
      expect(json['method'], equals('Muslim World League'));
      expect(json['latitude'], equals(34.0331));
      expect(json['longitude'], equals(-5.0003));
      expect(json['timezone'], equals('Africa/Casablanca'));
      expect(json['hijriDate'], isA<Map<String, dynamic>>());
    });

    test('toString returns readable representation', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson);
      final str = pt.toString();
      expect(str, contains('PrayerTimes'));
      expect(str, contains('fajr: 04:15 (UTC)'));
      expect(str, contains('isha: 20:15 (UTC)'));
    });
  });

  group('PrayerTime model', () {
    test('creates PrayerTime with all fields', () {
      final pt = PrayerTime(
        name: 'Fajr',
        time: '04:15',
        arabicName: 'الفجر',
        icon: 'assets/icons/fajr.svg',
      );
      expect(pt.name, equals('Fajr'));
      expect(pt.time, equals('04:15'));
      expect(pt.arabicName, equals('الفجر'));
      expect(pt.icon, equals('assets/icons/fajr.svg'));
    });

    test('isFard is true for non-Sunrise prayers', () {
      expect(PrayerTime(name: 'Fajr', time: '04:15', arabicName: '', icon: '').isFard, isTrue);
      expect(PrayerTime(name: 'Dhuhr', time: '12:30', arabicName: '', icon: '').isFard, isTrue);
      expect(PrayerTime(name: 'Asr', time: '16:00', arabicName: '', icon: '').isFard, isTrue);
      expect(PrayerTime(name: 'Maghrib', time: '18:45', arabicName: '', icon: '').isFard, isTrue);
      expect(PrayerTime(name: 'Isha', time: '20:15', arabicName: '', icon: '').isFard, isTrue);
    });

    test('isFard is false for Sunrise', () {
      expect(PrayerTime(name: 'Sunrise', time: '05:45', arabicName: '', icon: '').isFard, isFalse);
    });
  });

  group('prayers getter', () {
    test('returns 6 prayers in correct order', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson);
      final prayers = pt.prayers;

      expect(prayers.length, equals(6));
      expect(prayers[0].name, equals('Fajr'));
      expect(prayers[1].name, equals('Sunrise'));
      expect(prayers[2].name, equals('Dhuhr'));
      expect(prayers[3].name, equals('Asr'));
      expect(prayers[4].name, equals('Maghrib'));
      expect(prayers[5].name, equals('Isha'));
    });

    test('prayers have correct arabic names', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson);
      final prayers = pt.prayers;

      expect(prayers[0].arabicName, equals('الفجر'));
      expect(prayers[1].arabicName, equals('الشروق'));
      expect(prayers[2].arabicName, equals('الظهر'));
      expect(prayers[3].arabicName, equals('العصر'));
      expect(prayers[4].arabicName, equals('المغرب'));
      expect(prayers[5].arabicName, equals('العشاء'));
    });

    test('prayers have correct icon paths', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson);
      final prayers = pt.prayers;

      expect(prayers[0].icon, equals('assets/icons/fajr.svg'));
      expect(prayers[1].icon, equals('assets/icons/sunrise.svg'));
      expect(prayers[2].icon, equals('assets/icons/dhuhr.svg'));
      expect(prayers[3].icon, equals('assets/icons/asr.svg'));
      expect(prayers[4].icon, equals('assets/icons/maghrib.svg'));
      expect(prayers[5].icon, equals('assets/icons/isha.svg'));
    });
  });

  group('Hijri date conversion', () {
    test('parses Hijri date from JSON correctly', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson);
      final hijri = pt.hijriDate;

      expect(hijri.day, equals('18'));
      expect(hijri.month, equals('Dhuʻl-Hijjah'));
      expect(hijri.year, equals('1446'));
      expect(hijri.monthNumber, equals('12'));
      expect(hijri.weekday, equals('Sunday'));
      expect(hijri.weekdayArabic, equals('الاحد'));
    });

    test('formatted returns "day month year"', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson);
      expect(pt.hijriDate.formatted, equals('18 Dhuʻl-Hijjah 1446'));
    });

    test('formattedArabic returns with هـ suffix', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson);
      expect(pt.hijriDate.formattedArabic, equals('18 Dhuʻl-Hijjah 1446هـ'));
    });

    test('handles missing hijri data with empty strings', () {
      final json = {
        'date': {'readable': '15 Jun 2025'},
        'timings': {},
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      final hijri = pt.hijriDate;

      expect(hijri.day, equals(''));
      expect(hijri.month, equals(''));
      expect(hijri.year, equals(''));
      expect(hijri.monthNumber, equals(''));
      expect(hijri.weekday, equals(''));
      expect(hijri.weekdayArabic, equals(''));
    });

    test('handles missing weekday fields', () {
      final json = {
        'date': {
          'readable': '15 Jun 2025',
          'hijri': {
            'day': '18',
            'month': {'en': 'Muharram', 'number': 1},
            'year': '1447',
          },
        },
        'timings': {},
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      final hijri = pt.hijriDate;

      expect(hijri.weekday, equals(''));
      expect(hijri.weekdayArabic, equals(''));
    });

    test('handles missing month number', () {
      final json = {
        'date': {
          'readable': '15 Jun 2025',
          'hijri': {
            'day': '18',
            'month': {'en': 'Muharram'},
            'year': '1447',
          },
        },
        'timings': {},
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.hijriDate.monthNumber, equals(''));
    });

    test('HijriDate toJson round-trip', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson);
      final json = pt.hijriDate.toJson();

      expect(json['day'], equals('18'));
      expect(json['month'], equals('Dhuʻl-Hijjah'));
      expect(json['year'], equals('1446'));
      expect(json['monthNumber'], equals('12'));
      expect(json['weekday'], equals('Sunday'));
      expect(json['weekdayArabic'], equals('الاحد'));
    });

    test('HijriDate fromJson with integer year', () {
      final json = {
        'day': '1',
        'month': {'en': 'Muharram', 'number': 1},
        'year': 1447,
        'weekday': {'en': 'Monday', 'ar': 'الاثنين'},
      };
      final hijri = HijriDate.fromJson(json);
      expect(hijri.year, equals('1447'));
    });
  });

  group('Next prayer calculation', () {
    test('returns first prayer when all prayers have passed (next day Fajr)', () {
      final now = DateTime.now();
      // All times are in the past
      final json = {
        'date': {'readable': '${now.day} ${_monthName(now.month)} ${now.year}'},
        'timings': {
          'Fajr': '00:01',
          'Sunrise': '00:02',
          'Dhuhr': '00:03',
          'Asr': '00:04',
          'Maghrib': '00:05',
          'Isha': '00:06',
        },
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      final next = pt.nextPrayer;
      expect(next, isNotNull);
      expect(next!.name, equals('Fajr'));
    });

    test('returns null-equivalent first prayer when all passed', () {
      final now = DateTime.now();
      final json = {
        'date': {'readable': '${now.day} ${_monthName(now.month)} ${now.year}'},
        'timings': {
          'Fajr': '00:01',
          'Sunrise': '00:02',
          'Dhuhr': '00:03',
          'Asr': '00:04',
          'Maghrib': '00:05',
          'Isha': '00:06',
        },
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      // nextPrayer should return prayers.first (Fajr) when all have passed
      expect(pt.nextPrayer?.name, equals('Fajr'));
    });

    test('returns correct prayer when some are in the future', () {
      final now = DateTime.now();
      final futureHour = (now.hour + 1) % 24;
      final pastHour = (now.hour - 1) % 24;
      final json = {
        'date': {'readable': '${now.day} ${_monthName(now.month)} ${now.year}'},
        'timings': {
          // _parseTime expects "HH:mm" without timezone suffix
          'Fajr': '${pastHour.toString().padLeft(2, '0')}:00',
          'Sunrise': '${pastHour.toString().padLeft(2, '0')}:15',
          'Dhuhr': '${futureHour.toString().padLeft(2, '0')}:00',
          'Asr': '${futureHour.toString().padLeft(2, '0')}:30',
          'Maghrib': '${(futureHour + 1) % 24}:00',
          'Isha': '${(futureHour + 2) % 24}:00',
        },
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      final next = pt.nextPrayer;
      expect(next, isNotNull);
      // Dhuhr should be the next prayer since Fajr and Sunrise are in the past
      expect(next!.name, equals('Dhuhr'));
    });
  });

  group('Edge cases', () {
    test('handles empty JSON gracefully', () {
      final json = <String, dynamic>{
        'timings': {},
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.fajr, equals(''));
      expect(pt.method, equals(''));
    });

    test('handles null timings map', () {
      final json = {
        'date': {'readable': '15 Jun 2025'},
        'timings': null,
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.fajr, equals(''));
    });

    test('handles null meta map', () {
      final json = {
        'date': {'readable': '15 Jun 2025'},
        'timings': {},
        'meta': null,
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.method, equals(''));
    });

    test('handles timezone with special characters', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson,
          lat: 0, lng: 0, tz: 'America/New_York');
      expect(pt.timezone, equals('America/New_York'));
    });

    test('handles negative longitude', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson,
          lat: 40.7128, lng: -74.0060, tz: 'America/New_York');
      expect(pt.longitude, equals(-74.0060));
    });

    test('handles high latitude coordinates', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson,
          lat: 71.7069, lng: -42.6043, tz: 'America/Godthab');
      expect(pt.latitude, equals(71.7069));
      expect(pt.longitude, equals(-42.6043));
    });

    test('handles equatorial coordinates', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson,
          lat: 0.0, lng: 0.0, tz: 'UTC');
      expect(pt.latitude, equals(0.0));
      expect(pt.longitude, equals(0.0));
    });

    test('handles extreme southern latitude', () {
      final pt = PrayerTimes.fromJson(sampleAladhanJson,
          lat: -54.2806, lng: -36.5090, tz: 'Atlantic/South_Georgia');
      expect(pt.latitude, equals(-54.2806));
    });

    test('handles prayer times at midnight boundary', () {
      final json = {
        'date': {'readable': '15 Jun 2025'},
        'timings': {
          'Fajr': '00:00',
          'Sunrise': '00:01',
          'Dhuhr': '12:00',
          'Asr': '15:00',
          'Maghrib': '23:59',
          'Isha': '23:58',
        },
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.fajr, equals('00:00'));
      expect(pt.maghrib, equals('23:59'));
    });

    test('handles prayer times with parentheses in time string', () {
      final json = {
        'date': {'readable': '15 Jun 2025'},
        'timings': {
          'Fajr': '04:15 (WEST)',
          'Sunrise': '05:45 (WEST)',
          'Dhuhr': '12:30 (WEST)',
          'Asr': '16:00 (WEST)',
          'Maghrib': '18:45 (WEST)',
          'Isha': '20:15 (WEST)',
        },
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.fajr, equals('04:15 (WEST)'));
      expect(pt.isha, equals('20:15 (WEST)'));
    });

    test('handles Hijri date with single-digit day', () {
      final json = {
        'date': {
          'readable': '15 Jun 2025',
          'hijri': {
            'day': '5',
            'month': {'en': 'Muharram', 'number': 1},
            'year': '1447',
            'weekday': {'en': 'Monday', 'ar': 'الاثنين'},
          },
        },
        'timings': {},
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.hijriDate.day, equals('5'));
      expect(pt.hijriDate.formatted, equals('5 Muharram 1447'));
    });

    test('handles Hijri month number as integer', () {
      final json = {
        'date': {
          'readable': '15 Jun 2025',
          'hijri': {
            'day': '10',
            'month': {'en': 'Ramadan', 'number': 9},
            'year': '1446',
          },
        },
        'timings': {},
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.hijriDate.monthNumber, equals('9'));
    });

    test('handles Hijri year as integer', () {
      final json = {
        'date': {
          'readable': '15 Jun 2025',
          'hijri': {
            'day': '1',
            'month': {'en': 'Muharram', 'number': 1},
            'year': 1447,
          },
        },
        'timings': {},
        'meta': {},
      };
      final pt = PrayerTimes.fromJson(json);
      expect(pt.hijriDate.year, equals('1447'));
    });
  });
}

String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[month - 1];
}

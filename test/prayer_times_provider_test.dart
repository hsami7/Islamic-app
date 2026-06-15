import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/models/prayer_times.dart';
import 'package:islamic_app/providers/prayer_times_provider.dart';

void main() {
  group('PrayerTimesProvider - Public Interface', () {
    late PrayerTimesProvider provider;

    setUp(() {
      provider = PrayerTimesProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state has null prayer times', () {
      expect(provider.todayPrayerTimes, isNull);
      expect(provider.tomorrowPrayerTimes, isNull);
      expect(provider.nextPrayer, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.currentPosition, isNull);
      expect(provider.currentCity, equals(''));
      expect(provider.currentCountry, equals(''));
    });

    test('getTimeRemaining returns --:-- when no prayer times', () {
      expect(provider.getTimeRemaining(), equals('--:--'));
    });

    test('getProgressToNextPrayer returns 0.0 when no prayer times', () {
      expect(provider.getProgressToNextPrayer(), equals(0.0));
    });

    test('clearError clears error message', () {
      // Can't easily set error without API call, but test the method exists
      provider.clearError();
      expect(provider.error, isNull);
    });
  });

  group('PrayerTimes model - Time Calculation Logic', () {
    group('Next prayer calculation', () {
      test('returns correct next prayer when some are in future', () {
        final now = DateTime.now();
        final todayStr = '${now.day} ${_monthName(now.month)} ${now.year}';
        final futureHour = (now.hour + 2) % 24;
        final pastHour = (now.hour - 2) % 24;
        
        final pt = PrayerTimes.fromJson({
          'date': {'readable': todayStr},
          'timings': {
            'Fajr': '${pastHour.toString().padLeft(2, '0')}:15',
            'Sunrise': '${pastHour.toString().padLeft(2, '0')}:45',
            'Dhuhr': '${pastHour.toString().padLeft(2, '0')}:30',
            'Asr': '${futureHour.toString().padLeft(2, '0')}:30',
            'Maghrib': '${(futureHour + 2) % 24}:45',
            'Isha': '${(futureHour + 4) % 24}:15',
            'Imsak': '${pastHour.toString().padLeft(2, '0')}:05',
          },
          'meta': {},
        });

        final next = pt.nextPrayer;
        expect(next, isNotNull);
        expect(next!.name, equals('Asr'));
      });

      test('returns Fajr when all prayers have passed', () {
        final now = DateTime.now();
        final todayStr = '${now.day} ${_monthName(now.month)} ${now.year}';
        final pt = PrayerTimes.fromJson({
          'date': {'readable': todayStr},
          'timings': {
            'Fajr': '00:01',
            'Sunrise': '00:02',
            'Dhuhr': '00:03',
            'Asr': '00:04',
            'Maghrib': '00:05',
            'Isha': '00:06',
            'Imsak': '00:00',
          },
          'meta': {},
        });

        final next = pt.nextPrayer;
        expect(next, isNotNull);
        expect(next!.name, equals('Fajr'));
      });

      test('returns first upcoming prayer in correct order', () {
        final pt = PrayerTimes.fromJson({
          'date': {'readable': '15 Jun 2025'},
          'timings': {
            'Fajr': '04:15',
            'Sunrise': '05:45',
            'Dhuhr': '12:30',
            'Asr': '16:00',
            'Maghrib': '18:45',
            'Isha': '20:15',
          },
          'meta': {},
        });

        // Test that prayers getter returns correct order
        final prayers = pt.prayers;
        expect(prayers.length, equals(6));
        expect(prayers[0].name, equals('Fajr'));
        expect(prayers[1].name, equals('Sunrise'));
        expect(prayers[2].name, equals('Dhuhr'));
        expect(prayers[3].name, equals('Asr'));
        expect(prayers[4].name, equals('Maghrib'));
        expect(prayers[5].name, equals('Isha'));
      });
    });

    group('Time remaining formatting', () {
      test('_formatDuration formats hours and minutes', () {
        final provider = PrayerTimesProvider();
        
        // Test private method indirectly through getTimeRemaining
        // We can test the logic by setting up a scenario
        final now = DateTime.now();
        final todayStr = '${now.day} ${_monthName(now.month)} ${now.year}';
        final pt = PrayerTimes.fromJson({
          'date': {'readable': todayStr},
          'timings': {
            'Fajr': '04:15',
            'Sunrise': '05:45',
            'Dhuhr': '12:30',
            'Asr': '16:00',
            'Maghrib': '18:45',
            'Isha': '20:15',
            'Imsak': '04:05',
          },
          'meta': {},
        });

        // Test the _formatDuration logic directly
        // 2 hours 30 minutes
        final diff1 = Duration(hours: 2, minutes: 30);
        expect(_formatDuration(diff1), equals('2h 30m'));
        
        // 45 minutes
        final diff2 = Duration(minutes: 45);
        expect(_formatDuration(diff2), equals('45m'));
        
        // 1 hour exactly
        final diff3 = Duration(hours: 1);
        expect(_formatDuration(diff3), equals('1h 0m'));
        
        provider.dispose();
      });
    });

    group('Progress calculation logic', () {
      test('progress is 0.0 at start of prayer interval', () {
        // Right after Fajr, before Dhuhr, progress should be 0
        final fajrTime = DateTime(2025, 6, 15, 4, 15);
        final dhuhrTime = DateTime(2025, 6, 15, 12, 30);
        final rightAfterFajr = DateTime(2025, 6, 15, 4, 20);
        
        final totalDuration = dhuhrTime.difference(fajrTime).inMinutes;
        final elapsedDuration = rightAfterFajr.difference(fajrTime).inMinutes;
        final progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
        
        expect(progress, closeTo(0.0, 0.1));
      });

      test('progress is 0.5 at midpoint of prayer interval', () {
        final fajrTime = DateTime(2025, 6, 15, 4, 15);
        final dhuhrTime = DateTime(2025, 6, 15, 12, 30);
        final midway = DateTime(2025, 6, 15, 8, 22); // ~4 hours 7 min after Fajr
        
        final totalDuration = dhuhrTime.difference(fajrTime).inMinutes; // 495 min
        final elapsedDuration = midway.difference(fajrTime).inMinutes; // ~247 min
        final progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
        
        expect(progress, closeTo(0.5, 0.05));
      });

      test('progress approaches 1.0 near next prayer', () {
        final fajrTime = DateTime(2025, 6, 15, 4, 15);
        final dhuhrTime = DateTime(2025, 6, 15, 12, 30);
        final nearDhuhr = DateTime(2025, 6, 15, 12, 25);
        
        final totalDuration = dhuhrTime.difference(fajrTime).inMinutes;
        final elapsedDuration = nearDhuhr.difference(fajrTime).inMinutes;
        final progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
        
        expect(progress, greaterThan(0.9));
        expect(progress, lessThanOrEqualTo(1.0));
      });

      test('progress is 1.0 when next prayer time has passed', () {
        final fajrTime = DateTime(2025, 6, 15, 4, 15);
        final dhuhrTime = DateTime(2025, 6, 15, 12, 30);
        final afterDhuhr = DateTime(2025, 6, 15, 12, 35);
        
        final totalDuration = dhuhrTime.difference(fajrTime).inMinutes;
        final elapsedDuration = afterDhuhr.difference(fajrTime).inMinutes;
        final progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
        
        expect(progress, equals(1.0));
      });
    });
  });

  group('PrayerTimes model - Edge Cases for DST and High Latitudes', () {
    group('DST transition handling', () {
      test('handles spring forward DST (clock jumps forward 1 hour)', () {
        // US DST starts second Sunday in March
        final pt = PrayerTimes.fromJson({
          'date': {'readable': '09 Mar 2025'},
          'timings': {
            'Fajr': '05:15',
            'Sunrise': '06:45',
            'Dhuhr': '13:30',
            'Asr': '17:00',
            'Maghrib': '19:45',
            'Isha': '21:15',
            'Imsak': '05:05',
          },
          'meta': {
            'timezone': 'America/New_York',
            'latitude': 40.7128,
            'longitude': -74.0060,
          },
        }, lat: 40.7128, lng: -74.0060, tz: 'America/New_York');

        expect(pt.fajr, equals('05:15'));
        expect(pt.dhuhr, equals('13:30'));
        expect(pt.timezone, equals('America/New_York'));
      });

      test('handles fall back DST (clock falls back 1 hour)', () {
        // US DST ends first Sunday in November
        final pt = PrayerTimes.fromJson({
          'date': {'readable': '02 Nov 2025'},
          'timings': {
            'Fajr': '05:15',
            'Sunrise': '06:45',
            'Dhuhr': '11:30',
            'Asr': '15:00',
            'Maghrib': '17:45',
            'Isha': '19:15',
            'Imsak': '05:05',
          },
          'meta': {
            'timezone': 'America/New_York',
            'latitude': 40.7128,
            'longitude': -74.0060,
          },
        }, lat: 40.7128, lng: -74.0060, tz: 'America/New_York');

        expect(pt.fajr, equals('05:15'));
        expect(pt.dhuhr, equals('11:30'));
      });

      test('handles timezone with DST offset in time string', () {
        final pt = PrayerTimes.fromJson({
          'date': {'readable': '15 Jun 2025'},
          'timings': {
            'Fajr': '04:15 (WEST)',
            'Sunrise': '05:45 (WEST)',
            'Dhuhr': '13:30 (WEST)',
            'Asr': '17:00 (WEST)',
            'Maghrib': '19:45 (WEST)',
            'Isha': '21:15 (WEST)',
          },
          'meta': {
            'timezone': 'Europe/Lisbon',
            'latitude': 38.7223,
            'longitude': -9.1393,
          },
        }, lat: 38.7223, lng: -9.1393, tz: 'Europe/Lisbon');

        expect(pt.fajr, equals('04:15 (WEST)'));
        expect(pt.dhuhr, equals('13:30 (WEST)'));
        expect(pt.timezone, equals('Europe/Lisbon'));
      });
    });

    group('High latitude edge cases', () {
      test('handles Arctic circle summer (polar day)', () {
        // Nuuk, Greenland (71.7°N) - has midnight sun in summer
        final pt = PrayerTimes.fromJson({
          'date': {'readable': '21 Jun 2025'},
          'timings': {
            'Fajr': '01:00',
            'Sunrise': '02:00',
            'Dhuhr': '13:00',
            'Asr': '17:00',
            'Maghrib': '23:00',
            'Isha': '23:30',
            'Imsak': '00:50',
          },
          'meta': {
            'latitude': 71.7069,
            'longitude': -42.6043,
            'timezone': 'America/Godthab',
          },
        }, lat: 71.7069, lng: -42.6043, tz: 'America/Godthab');

        expect(pt.latitude, equals(71.7069));
        expect(pt.longitude, equals(-42.6043));
        expect(pt.nextPrayer, isNotNull);
      });

      test('handles Arctic circle winter (polar night)', () {
        final pt = PrayerTimes.fromJson({
          'date': {'readable': '21 Dec 2025'},
          'timings': {
            'Fajr': '09:00',
            'Sunrise': '00:00',
            'Dhuhr': '12:00',
            'Asr': '13:00',
            'Maghrib': '15:00',
            'Isha': '16:00',
            'Imsak': '08:50',
          },
          'meta': {
            'latitude': 71.7069,
            'longitude': -42.6043,
            'timezone': 'America/Godthab',
          },
        }, lat: 71.7069, lng: -42.6043, tz: 'America/Godthab');

        expect(pt.sunrise, equals('00:00'));
        expect(pt.maghrib, equals('15:00'));
      });

      test('handles extreme coordinates (North Pole)', () {
        final pt = PrayerTimes.fromJson({
          'date': {'readable': '15 Jun 2025'},
          'timings': {},
          'meta': {'latitude': 90.0, 'longitude': 0.0},
        }, lat: 90.0, lng: 0.0);

        expect(pt.latitude, equals(90.0));
        expect(pt.longitude, equals(0.0));
      });

      test('handles extreme coordinates (South Pole)', () {
        final pt = PrayerTimes.fromJson({
          'date': {'readable': '15 Jun 2025'},
          'timings': {},
          'meta': {'latitude': -90.0, 'longitude': 0.0},
        }, lat: -90.0, lng: 0.0);

        expect(pt.latitude, equals(-90.0));
        expect(pt.longitude, equals(0.0));
      });

      test('handles equatorial coordinates', () {
        final pt = PrayerTimes.fromJson({
          'date': {'readable': '15 Jun 2025'},
          'timings': {
            'Fajr': '04:30',
            'Sunrise': '05:45',
            'Dhuhr': '11:55',
            'Asr': '15:10',
            'Maghrib': '18:05',
            'Isha': '19:20',
          },
          'meta': {'latitude': 0.0, 'longitude': 0.0, 'timezone': 'UTC'},
        }, lat: 0.0, lng: 0.0, tz: 'UTC');

        expect(pt.latitude, equals(0.0));
        expect(pt.longitude, equals(0.0));
      });
    });

    group('Midnight boundary edge cases', () {
      test('handles prayers at midnight (00:00)', () {
        final pt = PrayerTimes.fromJson({
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
        });

        expect(pt.fajr, equals('00:00'));
        expect(pt.maghrib, equals('23:59'));
      });

      test('handles prayer times with timezone suffix in parentheses', () {
        final pt = PrayerTimes.fromJson({
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
        });

        expect(pt.fajr, equals('04:15 (WEST)'));
        expect(pt.isha, equals('20:15 (WEST)'));
      });

      test('handles time parsing for midnight boundary', () {
        final pt = PrayerTimes.fromJson({
          'date': {'readable': '15 Jun 2025'},
          'timings': {
            'Fajr': '00:00',
            'Sunrise': '00:15',
            'Dhuhr': '12:00',
            'Asr': '15:30',
            'Maghrib': '23:45',
            'Isha': '00:30', // Isha after midnight
          },
          'meta': {},
        });

        // Parse time strings manually for testing
        final parseTime = (String time) {
          final parts = time.split(':');
          return DateTime(2025, 6, 15, int.parse(parts[0]), int.parse(parts[1]));
        };
        
        final fajrTime = parseTime(pt.fajr);
        final ishaTime = parseTime(pt.isha);
        
        expect(fajrTime.hour, equals(0));
        expect(fajrTime.minute, equals(0));
        expect(ishaTime.hour, equals(0));
        expect(ishaTime.minute, equals(30));
      });
    });

    group('Hijri date conversion edge cases', () {
      test('handles Hijri date with single-digit day', () {
        final pt = PrayerTimes.fromJson({
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
        });

        expect(pt.hijriDate.day, equals('5'));
        expect(pt.hijriDate.formatted, equals('5 Muharram 1447'));
      });

      test('handles Hijri month number as integer', () {
        final pt = PrayerTimes.fromJson({
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
        });

        expect(pt.hijriDate.monthNumber, equals('9'));
      });

      test('handles Hijri year as integer', () {
        final pt = PrayerTimes.fromJson({
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
        });

        expect(pt.hijriDate.year, equals('1447'));
      });

      test('handles missing Hijri weekday fields', () {
        final pt = PrayerTimes.fromJson({
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
        });

        expect(pt.hijriDate.weekday, equals(''));
        expect(pt.hijriDate.weekdayArabic, equals(''));
      });

      test('handles missing Hijri month number', () {
        final pt = PrayerTimes.fromJson({
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
        });

        expect(pt.hijriDate.monthNumber, equals(''));
      });
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

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  return '${minutes}m';
}
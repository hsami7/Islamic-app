import 'package:adhan/adhan.dart' as adhan;
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../models/prayer_times.dart';

/// Computes prayer times fully on-device (no network) using the `adhan`
/// astronomical library. Used as a fallback when the Aladhan API is
/// unreachable (DNS failure, offline, VPN leak, etc.) so the screen never
/// hard-fails with a raw error.
class PrayerCalculator {
  // Maps Aladhan API calculation-method IDs (used by settings.calculationMethod
  // and the URL `?method=`) to adhan CalculationMethod. Do NOT use adhan enum
  // ordinals — they differ from Aladhan's numbering.
  // Ref: https://aladhan.com/calculation-methods
  static adhan.CalculationMethod _mapMethod(int method) {
    switch (method) {
      case 0: // Shia Ithna-Ansari
        return adhan.CalculationMethod.other;
      case 1: // University of Islamic Sciences, Karachi
        return adhan.CalculationMethod.karachi;
      case 2: // Islamic Society of North America (ISNA)
        return adhan.CalculationMethod.north_america;
      case 3: // Muslim World League
        return adhan.CalculationMethod.muslim_world_league;
      case 4: // Umm Al-Qura, Makkah
        return adhan.CalculationMethod.umm_al_qura;
      case 5: // The Egyptian General Authority of Survey
        return adhan.CalculationMethod.egyptian;
      case 6: // Institute of Geophysics, University of Tehran
        return adhan.CalculationMethod.tehran;
      case 7: // Gulf Region
        return adhan.CalculationMethod.dubai;
      case 8: // Kuwait
        return adhan.CalculationMethod.kuwait;
      case 9: // Qatar
        return adhan.CalculationMethod.qatar;
      case 10: // Majlis Ugama Islam Singapura
        return adhan.CalculationMethod.singapore;
      case 11: // Union Organization islamic de France
        return adhan.CalculationMethod.other;
      case 12: // Diyanet İşleri Başkanlığı, Turkey
        return adhan.CalculationMethod.turkey;
      case 13: // Spiritual Administration of Muslims of Russia
        return adhan.CalculationMethod.other;
      case 14: // Moonsighting Committee
        return adhan.CalculationMethod.moon_sighting_committee;
      default:
        return adhan.CalculationMethod.muslim_world_league;
    }
  }

  static adhan.Madhab _mapMadhab(int madhab) {
    // 0 = Shafi, 1 = Hanafi
    return madhab == 1 ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
  }

  static PrayerTimes calculate({
    required double latitude,
    required double longitude,
    required int method,
    required int madhab,
    required DateTime date,
    String locale = 'en',
  }) {
    final params = _mapMethod(method).getParameters()..madhab = _mapMadhab(madhab);

    final pt = adhan.PrayerTimes(
      adhan.Coordinates(latitude, longitude),
      adhan.DateComponents(date.year, date.month, date.day),
      params,
    );

    // Next-day Fajr is needed for night-based times (midnight, last third).
    final tomorrow = date.add(const Duration(days: 1));
    final ptTomorrow = adhan.PrayerTimes(
      adhan.Coordinates(latitude, longitude),
      adhan.DateComponents(tomorrow.year, tomorrow.month, tomorrow.day),
      params,
    );

    final fmt = DateFormat.Hm('en_US'); // 24h "HH:mm", Latin digits always
    final fajr = pt.fajr;
    final maghrib = pt.maghrib;
    final imsak = fajr.subtract(const Duration(minutes: 10));
    final nextFajr = ptTomorrow.fajr;

    final nightDuration = nextFajr.difference(maghrib);
    final midnight = maghrib.add(nightDuration ~/ 2);
    final firstThird = maghrib.add(nightDuration ~/ 3);
    final lastThird = maghrib.add(nightDuration * 2 ~/ 3);

    // Hijri date (locale-aware month names)
    HijriCalendar.language = locale == 'ar' ? 'ar' : 'en';
    final hijri = HijriCalendar.fromDate(date);

    return PrayerTimes(
      date: date,
      fajr: fmt.format(fajr),
      sunrise: fmt.format(pt.sunrise),
      dhuhr: fmt.format(pt.dhuhr),
      asr: fmt.format(pt.asr),
      maghrib: fmt.format(maghrib),
      isha: fmt.format(pt.isha),
      imsak: fmt.format(imsak),
      midnight: fmt.format(midnight),
      firstThird: fmt.format(firstThird),
      lastThird: fmt.format(lastThird),
      method: _methodName(method),
      school: madhab == 1 ? 'Hanafi' : 'Shafi',
      latitude: latitude,
      longitude: longitude,
      timezone: '',
      hijriDate: HijriDate(
        day: hijri.hDay.toString(),
        month: hijri.getLongMonthName(),
        year: hijri.hYear.toString(),
        monthNumber: hijri.hMonth.toString(),
        weekday: hijri.getDayName(),
        weekdayArabic: hijri.getDayName(),
      ),
    );
  }

  static String _methodName(int method) {
    switch (method) {
      case 0:
        return 'Shia Ithna-Ansari';
      case 1:
        return 'Karachi';
      case 2:
        return 'ISNA';
      case 3:
        return 'Muslim World League';
      case 4:
        return 'Umm Al-Qura';
      case 5:
        return 'Egyptian';
      case 6:
        return 'Tehran';
      case 7:
        return 'Gulf Region';
      case 8:
        return 'Kuwait';
      case 9:
        return 'Qatar';
      case 10:
        return 'Singapore';
      case 11:
        return 'France';
      case 12:
        return 'Turkey';
      case 13:
        return 'Russia';
      case 14:
        return 'Moonsighting Committee';
      default:
        return 'Muslim World League';
    }
  }
}

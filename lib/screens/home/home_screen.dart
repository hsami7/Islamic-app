import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/numerals.dart';
import '../../constants/app_design.dart';
import '../../theme/islamic_theme.dart';
import '../../models/surah.dart';
import '../../models/prayer_times.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/azkar_provider.dart';
import '../../providers/quran_provider.dart';
import '../../services/storage_service.dart';
import '../../services/weather_service.dart';
import '../quran/quran_screen.dart';
import '../prayer_times/prayer_times_screen.dart';
import '../qibla/qibla_screen.dart';
import '../azkar/azkar_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherInfo? _weather;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final settings = context.read<SettingsProvider>();
    final w = await WeatherService.getCurrentWeather(settings.settings);
    if (mounted) {
      setState(() => _weather = w);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = IslamicTheme.of(context);
    final prayer = context.watch<PrayerTimesProvider>();
    final azkar = context.watch<AzkarProvider>();
    final quran = context.watch<QuranProvider>();

    final isArabic = settings.locale.languageCode == 'ar';

    return Scaffold(
      body: Stack(
        children: [
          // Weather-reactive sky background
          _SkyBackground(weather: _weather),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await prayer.refresh(settings);
                await _loadWeather();
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  _buildHeader(theme, isArabic, settings),
                  _buildSunArcCard(theme, prayer, isArabic),
                  _buildAzkarCard(theme, azkar, isArabic),
                  _buildQuranCard(theme, quran, settings, isArabic),
                  const SizedBox(height: IslamicSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(bool isArabic) {
    final h = DateTime.now().hour;
    if (isArabic) {
      if (h < 12) return 'صباح الخير';
      if (h < 17) return 'مساء الخير';
      if (h < 21) return 'مساء الخير';
      return 'تصبح على خير';
    }
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  Widget _buildHeader(IslamicTheme theme, bool isArabic, SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        IslamicSpacing.lg,
        IslamicSpacing.md,
        IslamicSpacing.lg,
        IslamicSpacing.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: const Icon(
              CupertinoIcons.person_fill,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: IslamicSpacing.sm),
          Expanded(
            child: Text(
              _greeting(isArabic),
              style: IslamicTextStyles.arabicMedium.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textDirection: ui.TextDirection.rtl,
            ),
          ),
          IconButton(
            icon: Icon(
              isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
              color: Colors.white,
            ),
            tooltip: isDark ? 'light_mode'.tr() : 'dark_mode'.tr(),
            onPressed: () {
              settings.setThemeMode(isDark ? 0 : 1);
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.bell_fill, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.line_horizontal_3, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// Sun-position arc + Hijri date + current/next prayer.
  Widget _buildSunArcCard(
    IslamicTheme theme,
    PrayerTimesProvider prayer,
    bool isArabic,
  ) {
    final hijri = prayer.todayPrayerTimes?.hijriDate;
    final dateText = hijri != null
        ? '${toLatinDigits(hijri.day)} ${_hijriMonthAr(hijri.monthNumber)} ${toLatinDigits(hijri.year)}'
        : (prayer.isLoading
            ? 'loading'.tr()
            : 'set_location_hint'.tr());

    final next = prayer.nextPrayer;
    final current = _currentPrayer(prayer);
    final prayerTime = next != null ? next.time : '';
    final religiousStatus = current?.arabicName ?? next?.arabicName ?? '';
    final religiousHint = current != null
        ? 'وقت ${current.arabicName}'
        : (next != null ? 'الوقت المتبقي' : (prayer.isLoading ? 'loading_prayer_times'.tr() : 'tap_to_refresh'.tr()));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.lg,
        vertical: IslamicSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IslamicRadius.xl),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(IslamicSpacing.lg),
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(IslamicRadius.xl),
              border: Border.all(
                color: theme.gold.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                _SunArc(progress: prayer.getProgressToNextPrayer()),
                const SizedBox(height: IslamicSpacing.md),
                Text(
                  dateText,
                  style: IslamicTextStyles.arabicMedium.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textDirection: ui.TextDirection.rtl,
                ),
                const SizedBox(height: IslamicSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$religiousStatus $prayerTime',
                      style: IslamicTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                      textDirection: ui.TextDirection.rtl,
                    ),
                    const SizedBox(width: IslamicSpacing.xs),
                    Text(
                      '🕌',
                      style: IslamicTextStyles.bodyMedium
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: IslamicSpacing.xs),
                Text(
                  religiousHint,
                  style: IslamicTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textDirection: ui.TextDirection.rtl,
                ),
                const SizedBox(height: IslamicSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => widget.onNavigate?.call(2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: IslamicSpacing.md,
                        vertical: IslamicSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: IslamicColors.accentGold,
                        borderRadius: BorderRadius.circular(IslamicRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🌅',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: IslamicSpacing.xs),
                          Text(
                            'لعل الدعاء مستجاب',
                            style: IslamicTextStyles.labelMedium.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAzkarCard(
    IslamicTheme theme,
    AzkarProvider azkar,
    bool isArabic,
  ) {
    final prayer = context.read<PrayerTimesProvider>();
    final categoryId = _azkarCategoryForTime(prayer);
    final category = azkar.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => azkar.categories.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.lg,
        vertical: IslamicSpacing.sm,
      ),
      child: GestureDetector(
        onTap: () => widget.onNavigate?.call(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(IslamicRadius.xl),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(IslamicSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(IslamicRadius.xl),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.sparkles,
                        color: IslamicColors.azkarRed,
                        size: 20,
                      ),
                      const SizedBox(width: IslamicSpacing.xs),
                      Expanded(
                        child: Text(
                          category.nameArabic,
                          style: IslamicTextStyles.arabicMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textDirection: ui.TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: IslamicSpacing.sm),
                  if (category.azkar.isNotEmpty)
                    Text(
                      category.azkar.first.textArabic,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: IslamicTextStyles.arabicMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 18,
                        height: 1.6,
                      ),
                      textDirection: ui.TextDirection.rtl,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuranCard(
    IslamicTheme theme,
    QuranProvider quran,
    SettingsProvider settings,
    bool isArabic,
  ) {
    final lastSurah = StorageService.getLastReadSurah();
    final surah = lastSurah > 0
        ? quran.surahs.where((s) => s.number == lastSurah).firstOrNull
        : null;
    final progress = surah != null
        ? StorageService.getReadingProgress(surah.number)
        : 0;

    String buttonLabel;
    String surahLabel;
    String ayahPreview;

    if (surah == null) {
      buttonLabel = 'ابدأ التلاوة';
      surahLabel = 'القرآن الكريم';
      ayahPreview = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
    } else {
      final total = surah.numberOfAyahs;
      final finished = progress >= total;
      if (finished) {
        buttonLabel = 'إعادة القراءة';
      } else if (progress <= 1) {
        buttonLabel = 'ابدأ التلاوة';
      } else {
        buttonLabel = 'متابعة القراءة';
      }
      surahLabel = surah.name;
      ayahPreview = '${surah.englishNameTranslation} • $progress / $total';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.lg,
        vertical: IslamicSpacing.sm,
      ),
      child: GestureDetector(
        onTap: () {
          if (surah != null) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => SurahDetailScreen(surah: surah),
              ),
            );
          } else {
            widget.onNavigate?.call(1);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(IslamicSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(IslamicRadius.xl),
            boxShadow: IslamicShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                surahLabel,
                style: IslamicTextStyles.arabicMedium.copyWith(
                  color: settings.isDarkMode
                      ? IslamicColors.darkLabelPrimary
                      : IslamicColors.labelPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textDirection: ui.TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IslamicSpacing.sm),
              Text(
                ayahPreview,
                style: IslamicTextStyles.arabicLarge.copyWith(
                  color: IslamicColors.labelSecondary,
                  fontSize: 24,
                  height: 1.6,
                ),
                textDirection: ui.TextDirection.rtl,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: IslamicSpacing.md),
              ElevatedButton(
                onPressed: () {
                  if (surah != null) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => SurahDetailScreen(surah: surah),
                      ),
                    );
                  } else {
                    widget.onNavigate?.call(1);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: IslamicColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: IslamicSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(IslamicRadius.pill),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      buttonLabel,
                      style: IslamicTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: IslamicSpacing.xs),
                    const Icon(
                      CupertinoIcons.arrow_left,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----- helpers -----

  PrayerTime? _currentPrayer(PrayerTimesProvider prayer) {
    final times = prayer.todayPrayerTimes;
    if (times == null) return null;
    final now = DateTime.now();
    PrayerTime? current;
    for (final p in times.prayers) {
      final t = _parse(p.time);
      if (t.isBefore(now)) {
        current = p;
      } else {
        break;
      }
    }
    // After Isha, "current" is Isha until next Fajr.
    return current ?? times.prayers.first;
  }

  DateTime _parse(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _azkarCategoryForTime(PrayerTimesProvider prayer) {
    final times = prayer.todayPrayerTimes;
    final now = DateTime.now();
    if (times == null) return 'daily';

    DateTime? fajr, sunrise, asr, maghrib;
    for (final p in times.prayers) {
      if (p.name == 'Fajr') fajr = _parse(p.time);
      if (p.name == 'Sunrise') sunrise = _parse(p.time);
      if (p.name == 'Asr') asr = _parse(p.time);
      if (p.name == 'Maghrib') maghrib = _parse(p.time);
    }

    if (fajr != null && now.isBefore(fajr)) return 'protection';
    if (sunrise != null && now.isBefore(sunrise)) return 'morning';
    if (asr != null && now.isBefore(asr)) return 'daily';
    if (maghrib != null && now.isBefore(maghrib)) return 'after_prayer';
    if (maghrib != null && now.isAfter(maghrib)) return 'evening';
    return 'daily';
  }

  String _toArabicNumerals(String input) {
    return toLatinDigits(input);
  }

  String _hijriMonthAr(String? number) {
    const months = {
      '1': 'محرم',
      '2': 'صفر',
      '3': 'ربيع الأول',
      '4': 'ربيع الآخر',
      '5': 'جمادى الأولى',
      '6': 'جمادى الآخرة',
      '7': 'رجب',
      '8': 'شعبان',
      '9': 'رمضان',
      '10': 'شوال',
      '11': 'ذو القعدة',
      '12': 'ذو الحجة',
    };
    return months[number] ?? '';
  }
}

/// Weather-reactive sky gradient behind the home screen.
class _SkyBackground extends StatelessWidget {
  final WeatherInfo? weather;

  const _SkyBackground({this.weather});

  @override
  Widget build(BuildContext context) {
    final condition = weather?.condition ?? WeatherCondition.clear;
    final hour = DateTime.now().hour;

    // Base gradient by time of day (dark, theme-consistent).
    List<Color> timeColors;
    if (hour >= 5 && hour < 8) {
      timeColors = [const Color(0xFF1A2238), const Color(0xFF2C3E66)]; // dawn
    } else if (hour >= 8 && hour < 17) {
      timeColors = [const Color(0xFF12203A), const Color(0xFF1E2E4D)]; // day
    } else if (hour >= 17 && hour < 20) {
      timeColors = [const Color(0xFF221A38), const Color(0xFF3A2A4D)]; // sunset
    } else {
      timeColors = [const Color(0xFF0B1026), const Color(0xFF1B2244)]; // night
    }

    // Weather tint over the gradient.
    Color? tint;
    if (condition == WeatherCondition.rain) {
      tint = Colors.blueGrey.withValues(alpha: 0.35);
    } else if (condition == WeatherCondition.clouds) {
      tint = Colors.grey.withValues(alpha: 0.25);
    } else if (condition == WeatherCondition.thunderstorm) {
      tint = Colors.indigo.withValues(alpha: 0.4);
    } else if (condition == WeatherCondition.snow) {
      tint = Colors.white.withValues(alpha: 0.2);
    } else if (condition == WeatherCondition.fog) {
      tint = Colors.grey.withValues(alpha: 0.35);
    }

    // Representative weather scene drawn on top.
    Widget scene;
    switch (condition) {
      case WeatherCondition.rain:
      case WeatherCondition.thunderstorm:
        scene = _RainScene(isStorm: condition == WeatherCondition.thunderstorm);
      case WeatherCondition.snow:
        scene = _SnowScene();
      case WeatherCondition.clouds:
        scene = _CloudScene();
      case WeatherCondition.fog:
        scene = _FogScene();
      case WeatherCondition.clear:
      default:
        scene = (hour < 6 || hour >= 19)
            ? _StarsOverlay()
            : _SunScene();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: timeColors,
        ),
      ),
      child: Stack(
        children: [
          if (tint != null) Container(color: tint),
          scene,
        ],
      ),
    );
  }
}

/// Sun glow for clear daytime skies.
class _SunScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 30,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              IslamicColors.accentGold.withValues(alpha: 0.9),
              IslamicColors.accentGold.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Drifting cloud puffs.
class _CloudScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _cloud(top: 70, left: 30, scale: 1.0),
        _cloud(top: 130, left: 180, scale: 0.7),
        _cloud(top: 40, left: 230, scale: 0.55),
      ],
    );
  }

  Widget _cloud({required double top, required double left, required double scale}) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 120,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), shape: BoxShape.circle)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Falling rain streaks.
class _RainScene extends StatelessWidget {
  final bool isStorm;
  const _RainScene({this.isStorm = false});

  @override
  Widget build(BuildContext context) {
    final rng = [0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 0.15, 0.35, 0.6, 0.8, 0.45, 0.95];
    return Stack(
      children: List.generate(rng.length, (i) {
        return Positioned(
          top: (i * 40.0) % (MediaQuery.of(context).size.height * 0.7),
          left: rng[i] * MediaQuery.of(context).size.width,
          child: Container(
            width: 2,
            height: isStorm ? 26 : 18,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// Snow dots.
class _SnowScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rng = [0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 0.15, 0.35, 0.6, 0.8];
    return Stack(
      children: List.generate(rng.length, (i) {
        return Positioned(
          top: (i * 55.0) % (MediaQuery.of(context).size.height * 0.7),
          left: rng[i] * MediaQuery.of(context).size.width,
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

/// Soft fog bands.
class _FogScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: 90, left: 0, right: 0, child: Container(height: 60, color: Colors.white.withValues(alpha: 0.08))),
        Positioned(top: 160, left: 0, right: 0, child: Container(height: 80, color: Colors.white.withValues(alpha: 0.06))),
        Positioned(top: 250, left: 0, right: 0, child: Container(height: 70, color: Colors.white.withValues(alpha: 0.05))),
      ],
    );
  }
}

/// Simple starfield for night/clear skies.
class _StarsOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rng = [0.1, 0.2, 0.35, 0.5, 0.6, 0.7, 0.8, 0.9, 0.15, 0.45, 0.75, 0.25, 0.55, 0.85, 0.4];
    return Stack(
      children: List.generate(rng.length, (i) {
        return Positioned(
          top: rng[i] * MediaQuery.of(context).size.height * 0.6,
          left: ((i * 37) % 100) / 100 * MediaQuery.of(context).size.width,
          child: Container(
            width: 2 + (i % 3).toDouble(),
            height: 2 + (i % 3).toDouble(),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

/// Half-circle arc showing the sun's journey from sunrise to sunset.
class _SunArc extends StatelessWidget {
  final double progress; // 0..1

  const _SunArc({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: CustomPaint(
        size: const Size(double.infinity, 90),
        painter: _SunArcPainter(progress: progress.clamp(0.0, 1.0)),
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;

  _SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height; // arc sits on the bottom edge
    // Keep the whole semicircle inside the canvas (no negative Y, no overflow).
    final radius = (size.width / 2 - 16).clamp(0.0, size.height - 12);

    // Faint full track (the sky path).
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTRB(cx - radius, cy - radius, cx + radius, cy + radius),
      0,
      pi,
      false,
      trackPaint,
    );

    // Gold progress arc: from sunrise (left) up to the sun's current angle.
    final angle = pi - (progress.clamp(0.0, 1.0) * pi);
    final progressPaint = Paint()
      ..color = IslamicColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTRB(cx - radius, cy - radius, cx + radius, cy + radius),
      pi, // start at left (sunrise)
      (pi - angle), // sweep up to current sun angle
      false,
      progressPaint,
    );

    final sunX = cx + radius * cos(angle);
    final sunY = cy - radius * sin(angle);

    // Glow
    final glow = Paint()
      ..color = IslamicColors.accentGold.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 16, glow);

    // Sun
    final sunPaint = Paint()..color = IslamicColors.accentGold;
    canvas.drawCircle(Offset(sunX, sunY), 9, sunPaint);
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter old) =>
      old.progress != progress;
}

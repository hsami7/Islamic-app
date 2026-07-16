import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/numerals.dart';
import '../../constants/app_design.dart';
import '../../theme/islamic_theme.dart';
import '../../models/prayer_times.dart';
import '../../providers/prayer_times_provider.dart';
import '../../widgets/hig.dart';
import '../../providers/settings_provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<PrayerTimesProvider>()
          .loadTodayPrayerTimes(context.read<SettingsProvider>());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final prayerProvider = context.watch<PrayerTimesProvider>();
    final theme = IslamicTheme.of(context);

    return Scaffold(
      backgroundColor: theme.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(prayerProvider, settings, theme),
          _buildDateHeader(prayerProvider, settings, theme),
          if (prayerProvider.isOffline)
            _buildOfflineNotice(prayerProvider, theme),
          if (prayerProvider.error != null &&
              prayerProvider.todayPrayerTimes == null)
            _buildErrorCard(prayerProvider, theme),
          _buildNextPrayerCard(prayerProvider, settings, theme),
          _buildTabBar(theme),
          _buildTabBarView(prayerProvider, settings, theme),
        ],
      ),
    );
  }

  Widget _buildDateHeader(
    PrayerTimesProvider provider,
    SettingsProvider settings,
    IslamicTheme theme,
  ) {
    final hijriDate = provider.todayPrayerTimes?.hijriDate;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          kHIGMargin,
          IslamicSpacing.md,
          kHIGMargin,
          IslamicSpacing.xs,
        ),
        child: Column(
          children: [
            if (hijriDate != null) ...[
              Text(
                settings.locale.languageCode == 'ar'
                    ? hijriDate.formattedArabic
                    : hijriDate.formatted,
                style: IslamicTextStyles.headlineMedium.copyWith(
                  color: theme.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                toLatinDigits(
                  DateFormat.yMMMMd(settings.locale.languageCode)
                      .format(DateTime.now()),
                ),
                style: IslamicTextStyles.bodyMedium.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ],
            if (provider.currentCity.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.location_fill,
                    size: 14,
                    color: theme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.currentCity,
                    style: IslamicTextStyles.bodySmall.copyWith(
                      color: theme.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    PrayerTimesProvider provider,
    SettingsProvider settings,
    IslamicTheme theme,
  ) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: theme.background,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'prayer_times'.tr(),
          style: IslamicTextStyles.titleLarge.copyWith(
            color: theme.textPrimary,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IslamicColors.prayerBlue.withValues(alpha: 0.12),
                IslamicColors.primaryGreen.withValues(alpha: 0.04),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(CupertinoIcons.refresh, color: theme.textPrimary),
          onPressed: () =>
              provider.refresh(context.read<SettingsProvider>()),
        ),
        IconButton(
          icon: Icon(CupertinoIcons.location_solid, color: theme.textPrimary),
          onPressed: () =>
              provider.refreshLocation(context.read<SettingsProvider>()),
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard(
    PrayerTimesProvider provider,
    SettingsProvider settings,
    IslamicTheme theme,
  ) {
    final nextPrayer = provider.nextPrayer;
    final timeRemaining = provider.getTimeRemaining();
    final progress = provider.getProgressToNextPrayer();

    if (nextPrayer == null) {
      if (provider.error != null && provider.todayPrayerTimes == null) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverToBoxAdapter(
        child: HIGCard(
          child: Center(
            child: Text(
              provider.isLoading
                  ? 'loading_prayer_times'.tr()
                  : 'tap_to_refresh'.tr(),
              style: IslamicTextStyles.bodyMedium.copyWith(
                color: theme.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: HIGCard(
        shadow: IslamicShadows.cardElevated,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'next_prayer'.tr(),
                  style: IslamicTextStyles.labelMedium.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: IslamicSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(IslamicRadius.pill),
                  ),
                  child: Text(
                    nextPrayer.arabicName.tr(),
                    style: IslamicTextStyles.labelSmall.copyWith(
                      color: theme.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: IslamicSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nextPrayer.time,
                  style: IslamicTextStyles.displayMedium.copyWith(
                    fontSize: 52,
                    fontWeight: FontWeight.w300,
                    color: theme.accent,
                  ),
                ),
                const SizedBox(width: IslamicSpacing.sm),
                Text(
                  timeRemaining,
                  style: IslamicTextStyles.headlineSmall.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: IslamicSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(IslamicRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: theme.separator.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(theme.accent),
              ),
            ),
            const SizedBox(height: IslamicSpacing.xs),
            Text(
              '${(progress * 100).round()}% ${'elapsed_since_last_prayer'.tr()}',
              style: IslamicTextStyles.bodySmall.copyWith(
                color: theme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineNotice(
    PrayerTimesProvider provider,
    IslamicTheme theme,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kHIGMargin,
          vertical: IslamicSpacing.xs,
        ),
        child: Container(
          padding: const EdgeInsets.all(IslamicSpacing.md),
          decoration: BoxDecoration(
            color: IslamicColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(IslamicRadius.lg),
            border: Border.all(
              color: IslamicColors.primaryGreen.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.wifi_exclamationmark,
                color: IslamicColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: IslamicSpacing.sm),
              Expanded(
                child: Text(
                  'offline_prayer_times'.tr(),
                  style: IslamicTextStyles.bodySmall.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    PrayerTimesProvider provider,
    IslamicTheme theme,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(kHIGMargin),
        child: HIGCard(
          color: IslamicColors.azkarRed.withValues(alpha: 0.1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                color: IslamicColors.azkarRed,
                size: 40,
              ),
              const SizedBox(height: IslamicSpacing.sm),
              Text(
                'prayer_load_failed'.tr(),
                style: IslamicTextStyles.titleMedium.copyWith(
                  color: IslamicColors.azkarRed,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IslamicSpacing.md),
              CupertinoButton.filled(
                onPressed: () =>
                    provider.refresh(context.read<SettingsProvider>()),
                borderRadius: BorderRadius.circular(IslamicRadius.pill),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(IslamicTheme theme) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        tabBar: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelStyle: IslamicTextStyles.labelMedium,
          unselectedLabelStyle: IslamicTextStyles.labelMedium,
          indicatorColor: theme.accent,
          indicatorWeight: 3,
          labelColor: theme.accent,
          unselectedLabelColor: theme.textTertiary,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'today'.tr()),
            Tab(text: 'week'.tr()),
            Tab(text: 'month'.tr()),
          ],
        ),
        backgroundColor: theme.background,
      ),
    );
  }

  Widget _buildTabBarView(
    PrayerTimesProvider provider,
    SettingsProvider settings,
    IslamicTheme theme,
  ) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(provider, settings, theme),
          _buildWeekView(provider, settings, theme),
          _buildMonthView(provider, settings, theme),
        ],
      ),
    );
  }

  Widget _buildTodayView(
    PrayerTimesProvider provider,
    SettingsProvider settings,
    IslamicTheme theme,
  ) {
    if (provider.todayPrayerTimes == null) {
      return Center(
        child: Text(
          provider.isLoading ? 'loading'.tr() : 'tap_to_refresh'.tr(),
          style: IslamicTextStyles.bodyMedium.copyWith(
            color: theme.textSecondary,
          ),
        ),
      );
    }

    final prayers = provider.todayPrayerTimes!.prayers;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        kHIGMargin,
        IslamicSpacing.sm,
        kHIGMargin,
        IslamicSpacing.lg,
      ),
      itemCount: prayers.length + 1, // +1 for imsak
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildPrayerCard(
            PrayerTime(
              name: 'Imsak',
              time: provider.todayPrayerTimes!.imsak,
              arabicName: 'الإمساك',
              icon: '',
            ),
            false,
            theme,
          );
        }
        final prayer = prayers[index - 1];
        return _buildPrayerCard(prayer, prayer.isFard, theme);
      },
    );
  }

  Widget _buildPrayerCard(
    PrayerTime prayer,
    bool isFard,
    IslamicTheme theme,
  ) {
    final now = DateTime.now();
    final prayerTime = _parseTime(prayer.time);
    final hasPassed = prayerTime.isBefore(now);

    return Container(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.md),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        boxShadow: IslamicShadows.card,
      ),
      padding: const EdgeInsets.all(IslamicSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isFard
                  ? theme.accent.withValues(alpha: 0.15)
                  : IslamicColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(IslamicRadius.md),
            ),
            child: Icon(
              _getPrayerIcon(prayer.name),
              color: isFard ? theme.accent : IslamicColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: IslamicSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      prayer.arabicName.tr(),
                      style: IslamicTextStyles.titleMedium.copyWith(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isFard) ...[
                      const SizedBox(width: IslamicSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: IslamicSpacing.xs,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: theme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(IslamicRadius.pill),
                        ),
                        child: Text(
                          'fard'.tr(),
                          style: IslamicTextStyles.labelSmall.copyWith(
                            color: theme.accent,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  prayer.name.tr(),
                  style: IslamicTextStyles.bodySmall.copyWith(
                    color: theme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                prayer.time,
                style: IslamicTextStyles.headlineSmall.copyWith(
                  color: hasPassed ? theme.textTertiary : theme.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                hasPassed ? 'passed'.tr() : 'remaining'.tr(),
                style: IslamicTextStyles.bodySmall.copyWith(
                  color: theme.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
      case 'imsak':
        return CupertinoIcons.sunrise_fill;
      case 'sunrise':
        return CupertinoIcons.sun_max_fill;
      case 'dhuhr':
        return CupertinoIcons.sun_max;
      case 'asr':
        return CupertinoIcons.sun_min;
      case 'maghrib':
        return CupertinoIcons.sunset_fill;
      case 'isha':
        return CupertinoIcons.moon_stars_fill;
      default:
        return CupertinoIcons.clock_fill;
    }
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Widget _buildWeekView(
    PrayerTimesProvider provider,
    SettingsProvider settings,
    IslamicTheme theme,
  ) {
    return FutureBuilder(
      future: provider.loadWeekPrayerTimes(context.read<SettingsProvider>()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return _buildPrayerTimesList(
          provider.getPrayerTimesRange(
            DateTime.now(),
            DateTime.now().add(const Duration(days: 7)),
          ),
          theme,
        );
      },
    );
  }

  Widget _buildMonthView(
    PrayerTimesProvider provider,
    SettingsProvider settings,
    IslamicTheme theme,
  ) {
    return FutureBuilder(
      future: provider.loadMonthPrayerTimes(context.read<SettingsProvider>()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        return _buildPrayerTimesList(
          provider.getPrayerTimesRange(
            DateTime(now.year, now.month, 1),
            DateTime(now.year, now.month, daysInMonth),
          ),
          theme,
        );
      },
    );
  }

  Widget _buildPrayerTimesList(
    List<PrayerTimes> times,
    IslamicTheme theme,
  ) {
    if (times.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.calendar,
                size: 48, color: theme.textTertiary),
            const SizedBox(height: IslamicSpacing.md),
            Text(
              'no_data'.tr(),
              style: IslamicTextStyles.bodyMedium.copyWith(
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        kHIGMargin,
        IslamicSpacing.sm,
        kHIGMargin,
        IslamicSpacing.lg,
      ),
      itemCount: times.length,
      itemBuilder: (context, index) {
        return _buildDayCard(times[index], theme);
      },
    );
  }

  Widget _buildDayCard(PrayerTimes day, IslamicTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.md),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        boxShadow: IslamicShadows.card,
      ),
      padding: const EdgeInsets.all(IslamicSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                toLatinDigits(
                  DateFormat.EEEE(theme.locale.languageCode).format(day.date),
                ),
                style: IslamicTextStyles.titleMedium.copyWith(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: IslamicSpacing.sm),
              Text(
                toLatinDigits(
                  DateFormat.d(theme.locale.languageCode).format(day.date),
                ),
                style: IslamicTextStyles.bodyMedium.copyWith(
                  color: theme.textSecondary,
                ),
              ),
              const Spacer(),
              if (day.hijriDate.day.isNotEmpty)
                Text(
                  theme.locale.languageCode == 'ar'
                      ? day.hijriDate.formattedArabic
                      : day.hijriDate.formatted,
                  style: IslamicTextStyles.bodySmall.copyWith(
                    color: theme.accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: IslamicSpacing.md),
          Wrap(
            spacing: IslamicSpacing.sm,
            runSpacing: IslamicSpacing.xs,
            children: day.prayers.where((p) => p.isFard).map((prayer) {
              final hasPassed =
                  _parseTime(prayer.time).isBefore(DateTime.now());
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: IslamicSpacing.md,
                  vertical: IslamicSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: hasPassed
                      ? theme.separator.withValues(alpha: 0.1)
                      : theme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(IslamicRadius.pill),
                  border: Border.all(
                    color: hasPassed
                        ? theme.separator
                        : theme.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${prayer.arabicName.tr()} ${prayer.time}',
                  style: IslamicTextStyles.labelSmall.copyWith(
                    color: hasPassed ? theme.textTertiary : theme.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _TabBarDelegate({required this.tabBar, required this.backgroundColor});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

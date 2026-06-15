import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../../constants/app_design.dart';
import '../../models/prayer_times.dart';
import '../../providers/prayer_times_provider.dart';
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
      context.read<PrayerTimesProvider>().loadTodayPrayerTimes(
          context.read<SettingsProvider>());
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
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? IslamicColors.darkSystemGroupedBackground
          : IslamicColors.systemGroupedBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(prayerProvider, settings),
          _buildNextPrayerCard(prayerProvider, settings),
          _buildTabBar(isDark),
          _buildTabBarView(prayerProvider, settings),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(PrayerTimesProvider provider, SettingsProvider settings) {
    final hijriDate = provider.todayPrayerTimes?.hijriDate;

    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'prayer_times'.tr(),
          style: IslamicTextStyles.titleLarge,
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IslamicColors.prayerBlue.withValues(alpha: 0.15),
                IslamicColors.primaryGreen.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hijriDate != null) ...[
                      Text(
                        settings.locale.languageCode == 'ar'
                            ? hijriDate.formattedArabic
                            : hijriDate.formatted,
                        style: IslamicTextStyles.headlineMedium.copyWith(
                          color: IslamicColors.prayerBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMMd(settings.locale.languageCode)
                            .format(DateTime.now()),
                        style: IslamicTextStyles.bodyMedium.copyWith(
                          color: IslamicColors.labelSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (provider.currentCity.isNotEmpty)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.location_fill,
                        size: 14,
                        color: IslamicColors.labelTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.currentCity,
                        style: IslamicTextStyles.bodySmall.copyWith(
                          color: IslamicColors.labelTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.refresh),
          onPressed: () => provider.refresh(context.read<SettingsProvider>()),
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.location_solid),
          onPressed: () => provider.refreshLocation(context.read<SettingsProvider>()),
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard(PrayerTimesProvider provider, SettingsProvider settings) {
    final nextPrayer = provider.nextPrayer;
    final timeRemaining = provider.getTimeRemaining();
    final progress = provider.getProgressToNextPrayer();

    if (nextPrayer == null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(IslamicSpacing.md),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(IslamicSpacing.lg),
              child: Center(
                child: Text(
                  'loading_prayer_times'.tr(),
                  style: IslamicTextStyles.bodyMedium,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(IslamicSpacing.md),
        child: Card(
          elevation: 2,
          shadowColor: IslamicColors.prayerBlue.withValues(alpha: 0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(IslamicRadius.lg),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  IslamicColors.prayerBlue.withValues(alpha: 0.15),
                  IslamicColors.primaryGreen.withValues(alpha: 0.1),
                ],
              ),
            ),
            padding: const EdgeInsets.all(IslamicSpacing.lg),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'next_prayer'.tr(),
                      style: IslamicTextStyles.labelMedium.copyWith(
                        color: IslamicColors.labelSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: IslamicSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: IslamicColors.prayerBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(IslamicRadius.pill),
                      ),
                      child: Text(
                        nextPrayer.arabicName.tr(),
                        style: IslamicTextStyles.labelSmall.copyWith(
                          color: IslamicColors.prayerBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IslamicSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nextPrayer.time,
                      style: IslamicTextStyles.displayMedium.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: IslamicColors.prayerBlue,
                      ),
                    ),
                    const SizedBox(width: IslamicSpacing.sm),
                    Text(
                      timeRemaining,
                      style: IslamicTextStyles.headlineSmall.copyWith(
                        color: IslamicColors.labelSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IslamicSpacing.md),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(IslamicRadius.pill),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: IslamicColors.secondaryGreen,
                    valueColor: AlwaysStoppedAnimation<Color>(IslamicColors.prayerBlue),
                  ),
                ),
                const SizedBox(height: IslamicSpacing.xs),
                Text(
                  '${(progress * 100).round()}% ${'elapsed_since_last_prayer'.tr()}',
                  style: IslamicTextStyles.bodySmall.copyWith(
                    color: IslamicColors.labelTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        tabBar: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelStyle: IslamicTextStyles.labelMedium,
          unselectedLabelStyle: IslamicTextStyles.labelMedium,
          indicatorColor: IslamicColors.prayerBlue,
          indicatorWeight: 3,
          labelColor: IslamicColors.prayerBlue,
          unselectedLabelColor: isDark
              ? IslamicColors.darkLabelTertiary
              : IslamicColors.labelTertiary,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'today'.tr()),
            Tab(text: 'week'.tr()),
            Tab(text: 'month'.tr()),
          ],
        ),
        backgroundColor: isDark
            ? IslamicColors.darkSystemBackground
            : IslamicColors.systemBackground,
      ),
    );
  }

  Widget _buildTabBarView(PrayerTimesProvider provider, SettingsProvider settings) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(provider, settings),
          _buildWeekView(provider, settings),
          _buildMonthView(provider, settings),
        ],
      ),
    );
  }

  Widget _buildTodayView(PrayerTimesProvider provider, SettingsProvider settings) {
    if (provider.todayPrayerTimes == null) {
      return Center(child: Text('loading'.tr()));
    }

    final prayers = provider.todayPrayerTimes!.prayers;

    return ListView.builder(
      padding: const EdgeInsets.all(IslamicSpacing.md),
      itemCount: prayers.length + 1, // +1 for sunrise
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
            settings,
          );
        }
        final prayer = prayers[index - 1];
        return _buildPrayerCard(prayer, prayer.isFard, settings);
      },
    );
  }

  Widget _buildPrayerCard(PrayerTime prayer, bool isFard, SettingsProvider settings) {
    final now = DateTime.now();
    final prayerTime = _parseTime(prayer.time);
    final hasPassed = prayerTime.isBefore(now);

    return Card(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(IslamicSpacing.md),
        child: Row(
          children: [
            // Prayer icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isFard
                    ? IslamicColors.prayerBlue.withValues(alpha: 0.15)
                    : IslamicColors.secondaryGreen,
                borderRadius: BorderRadius.circular(IslamicRadius.md),
              ),
              child: Icon(
                _getPrayerIcon(prayer.name),
                color: isFard ? IslamicColors.prayerBlue : IslamicColors.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: IslamicSpacing.md),

            // Prayer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        prayer.arabicName.tr(),
                        style: IslamicTextStyles.titleMedium.copyWith(
                          color: IslamicColors.labelPrimary,
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
                            color: IslamicColors.prayerBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(IslamicRadius.pill),
                          ),
                          child: Text(
                            'fard'.tr(),
                            style: IslamicTextStyles.labelSmall.copyWith(
                              color: IslamicColors.prayerBlue,
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
                      color: IslamicColors.labelTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  prayer.time,
                  style: IslamicTextStyles.headlineSmall.copyWith(
                    color: hasPassed
                        ? IslamicColors.labelTertiary
                        : IslamicColors.prayerBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  hasPassed ? 'passed'.tr() : 'remaining'.tr(),
                  style: IslamicTextStyles.bodySmall.copyWith(
                    color: IslamicColors.labelTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
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
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  Widget _buildWeekView(PrayerTimesProvider provider, SettingsProvider settings) {
    return FutureBuilder(
      future: provider.loadWeekPrayerTimes(context.read<SettingsProvider>()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildPrayerTimesList(
          provider.getPrayerTimesRange(
            DateTime.now(),
            DateTime.now().add(const Duration(days: 7)),
          ),
          settings,
        );
      },
    );
  }

  Widget _buildMonthView(PrayerTimesProvider provider, SettingsProvider settings) {
    return FutureBuilder(
      future: provider.loadMonthPrayerTimes(context.read<SettingsProvider>()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        return _buildPrayerTimesList(
          provider.getPrayerTimesRange(
            DateTime(now.year, now.month, 1),
            DateTime(now.year, now.month, daysInMonth),
          ),
          settings,
        );
      },
    );
  }

  Widget _buildPrayerTimesList(
    List<PrayerTimes> times,
    SettingsProvider settings,
  ) {
    if (times.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.calendar, size: 48, color: IslamicColors.labelTertiary),
            const SizedBox(height: IslamicSpacing.md),
            Text('no_data'.tr(), style: IslamicTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(IslamicSpacing.md),
      itemCount: times.length,
      itemBuilder: (context, index) {
        return _buildDayCard(times[index], settings);
      },
    );
  }

  Widget _buildDayCard(PrayerTimes day, SettingsProvider settings) {
    return Card(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(IslamicSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  DateFormat.EEEE(settings.locale.languageCode).format(day.date),
                  style: IslamicTextStyles.titleMedium.copyWith(
                    color: IslamicColors.labelPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: IslamicSpacing.sm),
                Text(
                  DateFormat.d(settings.locale.languageCode).format(day.date),
                  style: IslamicTextStyles.bodyMedium.copyWith(
                    color: IslamicColors.labelSecondary,
                  ),
                ),
                const Spacer(),
                if (day.hijriDate.day.isNotEmpty)
                  Text(
                    settings.locale.languageCode == 'ar'
                        ? day.hijriDate.formattedArabic
                        : day.hijriDate.formatted,
                    style: IslamicTextStyles.bodySmall.copyWith(
                      color: IslamicColors.prayerBlue,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: IslamicSpacing.md),
            Wrap(
              spacing: IslamicSpacing.sm,
              runSpacing: IslamicSpacing.xs,
              children: day.prayers.where((p) => p.isFard).map((prayer) {
                final hasPassed = _parseTime(prayer.time).isBefore(DateTime.now());
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: IslamicSpacing.md,
                    vertical: IslamicSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: hasPassed
                        ? IslamicColors.separator.withValues(alpha: 0.1)
                        : IslamicColors.prayerBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(IslamicRadius.pill),
                    border: Border.all(
                      color: hasPassed
                          ? IslamicColors.separator
                          : IslamicColors.prayerBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${prayer.arabicName.tr()} ${prayer.time}',
                    style: IslamicTextStyles.labelSmall.copyWith(
                      color: hasPassed
                          ? IslamicColors.labelTertiary
                          : IslamicColors.prayerBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
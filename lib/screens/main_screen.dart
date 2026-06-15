import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_design.dart';
import '../constants/app_theme.dart';
import '../providers/index.dart';
import 'quran/quran_screen.dart';
import 'prayer_times/prayer_times_screen.dart';
import 'qibla/qibla_screen.dart';
import 'hadith/hadith_screen.dart';
import 'azkar/azkar_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const QuranScreen(),
    const PrayerTimesScreen(),
    const QiblaScreen(),
    const HadithScreen(),
    const AzkarScreen(),
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: CupertinoIcons.book_fill,
      label: 'quran',
      activeColor: IslamicColors.quranGold,
    ),
    NavigationItem(
      icon: CupertinoIcons.clock_fill,
      label: 'prayer_times',
      activeColor: IslamicColors.prayerBlue,
    ),
    NavigationItem(
      icon: CupertinoIcons.location_fill,
      label: 'qibla',
      activeColor: IslamicColors.qiblaOrange,
    ),
    NavigationItem(
      icon: CupertinoIcons.book_fill,
      label: 'hadith',
      activeColor: IslamicColors.hadithPurple,
    ),
    NavigationItem(
      icon: CupertinoIcons.sparkles,
      label: 'azkar',
      activeColor: IslamicColors.azkarRed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSurahs();
      context.read<PrayerTimesProvider>().loadTodayPrayerTimes(
          context.read<SettingsProvider>());
      context.read<QiblaProvider>().initialize(context.read<SettingsProvider>());
      context.read<HadithProvider>().loadCollections();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: IslamicDurations.standard,
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(settings),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar(SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    final bgColor = isDark ? IslamicColors.darkSystemBackground : IslamicColors.systemBackground;
    final separatorColor = isDark ? IslamicColors.darkSeparator : IslamicColors.separator;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: separatorColor, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: IslamicColors.labelPrimary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == _selectedIndex;
              final color = isSelected ? item.activeColor : (isDark ? IslamicColors.darkLabelTertiary : IslamicColors.labelTertiary);

              return Expanded(
                child: InkWell(
                  onTap: () => _onNavTap(index),
                  borderRadius: BorderRadius.circular(IslamicRadius.md),
                  child: AnimatedContainer(
                    duration: IslamicDurations.fast,
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: IslamicSpacing.sm),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: color,
                          size: isSelected ? 26 : 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label.tr(),
                          style: IslamicTextStyles.labelSmall.copyWith(
                            color: color,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Consumer<PrayerTimesProvider>(
      builder: (context, prayerProvider, _) {
        final nextPrayer = prayerProvider.nextPrayer;
        final timeRemaining = prayerProvider.getTimeRemaining();

        return Container(
          margin: const EdgeInsets.only(bottom: 72),
          child: FloatingActionButton.extended(
            onPressed: () {
              // Navigate to prayer times screen
              _onNavTap(1);
            },
            backgroundColor: IslamicColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(CupertinoIcons.clock_fill, size: 20),
            label: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nextPrayer != null ? nextPrayer.arabicName.tr() : 'prayer_times'.tr(),
                  style: IslamicTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
                Text(
                  timeRemaining,
                  style: IslamicTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            extendedPadding: const EdgeInsets.symmetric(horizontal: IslamicSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(IslamicRadius.pill),
            ),
          ),
        );
      },
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Color activeColor;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.activeColor,
  });
}
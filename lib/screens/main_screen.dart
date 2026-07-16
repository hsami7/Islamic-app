import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/app_design.dart';
import '../providers/index.dart';
import '../widgets/floating_nav_bar.dart';
import 'home/home_screen.dart';
import 'quran/quran_screen.dart';
import 'prayer_times/prayer_times_screen.dart';
import 'qibla/qibla_screen.dart';
import 'azkar/azkar_screen.dart';

/// Navigation index contract (shared with HomeScreen's onNavigate callbacks).
///   0 = Home, 1 = Quran, 2 = Prayer, 3 = Qibla, 4 = Azkar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSurahs();
      context.read<PrayerTimesProvider>().loadTodayPrayerTimes(
          context.read<SettingsProvider>());
      context.read<QiblaProvider>().initialize(context.read<SettingsProvider>());
    });
  }

  void _jumpTo(int index) {
    if (!mounted) return;
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: IslamicDurations.standard,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) => _jumpTo(index);

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Build screens here so HomeScreen receives the live navigation closure.
    final screens = [
      HomeScreen(onNavigate: _jumpTo),
      const QuranScreen(),
      const PrayerTimesScreen(),
      const QiblaScreen(),
      const AzkarScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: screens,
      ),
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../constants/app_design.dart';
import '../../providers/settings_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/azkar_provider.dart';
import '../../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? IslamicColors.darkSystemGroupedBackground
          : IslamicColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(settings),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildGeneralSection(settings),
              _buildPrayerTimesSection(settings),
              _buildQuranSection(settings),
              _buildNotificationsSection(settings),
              _buildAppearanceSection(settings),
              _buildAdvancedSection(settings),
              _buildAboutSection(settings),
              const SizedBox(height: IslamicSpacing.xl),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(SettingsProvider settings) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('settings'.tr(), style: IslamicTextStyles.titleLarge),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IslamicColors.primaryGreen.withValues(alpha: 0.15),
                IslamicColors.secondaryGreen.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        IslamicSpacing.md,
        IslamicSpacing.lg,
        IslamicSpacing.md,
        IslamicSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: IslamicSpacing.sm),
          Text(title, style: IslamicTextStyles.titleMedium.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('general'.tr(), CupertinoIcons.gear, IslamicColors.primaryGreen),
        _buildSettingsCard([
          _buildListTile(
            'language'.tr(),
            settings.locale.languageCode == 'ar' ? 'arabic'.tr() : 'english'.tr(),
            CupertinoIcons.globe,
            onTap: () => _showLanguagePicker(settings),
          ),
          _buildListTile(
            'theme'.tr(),
            _getThemeLabel(settings),
            CupertinoIcons.paintbrush,
            onTap: () => _showThemePicker(settings),
          ),
        ]),
      ],
    );
  }

  Widget _buildPrayerTimesSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('prayer_times'.tr(), CupertinoIcons.clock, IslamicColors.prayerBlue),
        _buildSettingsCard([
          _buildListTile(
            'calculation_method'.tr(),
            settings.settings.calculationMethod.toString(),
            CupertinoIcons.gear_alt,
            onTap: () => _showCalculationMethodPicker(settings),
          ),
          _buildListTile(
            'madhab'.tr(),
            _getMadhabLabel(settings),
            CupertinoIcons.book,
            onTap: () => _showMadhabPicker(settings),
          ),
        ]),
      ],
    );
  }

  Widget _buildQuranSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('quran_settings'.tr(), CupertinoIcons.book, IslamicColors.quranGold),
        _buildSettingsCard([
          _buildSliderTile(
            'font_size'.tr(),
            settings.settings.quranFontSize.toStringAsFixed(0),
            CupertinoIcons.textformat_size,
            value: settings.settings.quranFontSize,
            min: 18,
            max: 40,
            divisions: 22,
            onChanged: (v) => settings.setQuranFontSize(v),
          ),
          _buildSwitchTile(
            'show_translation'.tr(),
            CupertinoIcons.text_bubble,
            value: settings.settings.showTranslation,
            onChanged: (v) => settings.setShowTranslation(v),
          ),
          _buildListTile(
            'translation_language'.tr(),
            _getTranslationLanguageLabel(settings),
            CupertinoIcons.globe,
            onTap: () => _showTranslationPicker(settings),
          ),
          _buildSwitchTile(
            'auto_play_audio'.tr(),
            CupertinoIcons.play,
            value: settings.settings.quranAudioAutoPlay,
            onChanged: (v) => settings.setQuranAudioAutoPlay(v),
          ),
          _buildListTile(
            'reciter'.tr(),
            settings.settings.quranReciter,
            CupertinoIcons.music_note,
            onTap: () => _showReciterPicker(settings),
          ),
        ]),
      ],
    );
  }

  Widget _buildNotificationsSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('notifications'.tr(), CupertinoIcons.bell, IslamicColors.azkarRed),
        _buildSettingsCard([
          _buildSwitchTile(
            'prayer_notifications'.tr(),
            CupertinoIcons.bell_fill,
            value: settings.settings.notificationsEnabled,
            onChanged: (v) => settings.setNotificationsEnabled(v),
          ),
          if (settings.settings.notificationsEnabled) ...[
            _buildListTile(
              'advance_minutes'.tr(),
              '${settings.settings.notificationAdvanceMinutes} min',
              CupertinoIcons.timer,
              onTap: () => _showAdvanceMinutesPicker(settings),
            ),
            _buildSwitchTile(
              'fajr_notification'.tr(),
              CupertinoIcons.sunrise,
              value: settings.settings.fajrNotification,
              onChanged: (v) => settings.setPrayerNotification('fajr', v),
            ),
            _buildSwitchTile(
              'dhuhr_notification'.tr(),
              CupertinoIcons.sun_max,
              value: settings.settings.dhuhrNotification,
              onChanged: (v) => settings.setPrayerNotification('dhuhr', v),
            ),
            _buildSwitchTile(
              'asr_notification'.tr(),
              CupertinoIcons.sun_min,
              value: settings.settings.asrNotification,
              onChanged: (v) => settings.setPrayerNotification('asr', v),
            ),
            _buildSwitchTile(
              'maghrib_notification'.tr(),
              CupertinoIcons.sunset,
              value: settings.settings.maghribNotification,
              onChanged: (v) => settings.setPrayerNotification('maghrib', v),
            ),
            _buildSwitchTile(
              'isha_notification'.tr(),
              CupertinoIcons.moon,
              value: settings.settings.ishaNotification,
              onChanged: (v) => settings.setPrayerNotification('isha', v),
            ),
          ],
        ]),
      ],
    );
  }

  Widget _buildAppearanceSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('general'.tr(), CupertinoIcons.paintbrush, IslamicColors.hadithPurple),
        _buildSettingsCard([
          _buildSwitchTile(
            'haptic_feedback'.tr(),
            CupertinoIcons.hand_raised,
            value: settings.settings.hapticFeedback,
            onChanged: (v) => settings.setHapticFeedback(v),
          ),
          _buildSwitchTile(
            'reduce_motion'.tr(),
            CupertinoIcons.arrow_up_down,
            value: settings.settings.reduceMotion,
            onChanged: (v) => settings.setReduceMotion(v),
          ),
        ]),
      ],
    );
  }

  Widget _buildAdvancedSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('advanced'.tr(), CupertinoIcons.wrench, IslamicColors.qiblaOrange),
        _buildSettingsCard([
          _buildListTile(
            'clear_cache'.tr(),
            '',
            CupertinoIcons.trash,
            onTap: () => _clearCache(),
            showChevron: true,
              trailing: const Text(''),
          ),
          _buildListTile(
            'reset_azkar_progress'.tr(),
            '',
            CupertinoIcons.arrow_counterclockwise,
            onTap: () => _resetAzkarProgress(),
            showChevron: true,
          ),
          _buildListTile(
            'export_data'.tr(),
            '',
            CupertinoIcons.square_arrow_up,
            onTap: () => _exportData(),
            showChevron: true,
          ),
          _buildListTile(
            'import_data'.tr(),
            '',
            CupertinoIcons.square_arrow_down,
            onTap: () => _importData(),
            showChevron: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildAboutSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('about'.tr(), CupertinoIcons.info, IslamicColors.labelSecondary),
        _buildSettingsCard([
          _buildListTile(
            'version'.tr(),
            '1.0.0',
            CupertinoIcons.tag,
            showChevron: false,
          ),
          _buildListTile(
            'privacy_policy'.tr(),
            '',
            CupertinoIcons.doc_text,
            onTap: () {},
          ),
          _buildListTile(
            'terms_of_service'.tr(),
            '',
            CupertinoIcons.doc_text_fill,
            onTap: () {},
          ),
          _buildListTile(
            'rate_app'.tr(),
            '',
            CupertinoIcons.star,
            onTap: () {},
          ),
          _buildListTile(
            'share_app'.tr(),
            '',
            CupertinoIcons.share,
            onTap: () {},
          ),
        ]),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: IslamicSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? IslamicColors.darkSecondarySystemBackground : IslamicColors.systemBackground,
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        border: Border.all(
          color: isDark ? IslamicColors.darkSeparator : IslamicColors.separator,
        ),
      ),
      child: Column(
        children: children.map((child) {
          final index = children.indexOf(child);
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isDark ? IslamicColors.darkSeparator : IslamicColors.separator,
                  indent: IslamicSpacing.lg,
                  endIndent: IslamicSpacing.md,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    bool showChevron = true,
    Widget? trailing,
  }) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return ListTile(
      leading: Icon(icon, color: isDark ? IslamicColors.darkLabelSecondary : IslamicColors.labelSecondary),
      title: Text(title, style: IslamicTextStyles.bodyLarge),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: IslamicTextStyles.bodySmall.copyWith(color: IslamicColors.labelTertiary))
          : null,
      trailing: trailing ??
          (showChevron
              ? Icon(
                  CupertinoIcons.chevron_right,
                  color: isDark ? IslamicColors.darkLabelTertiary : IslamicColors.labelTertiary,
                )
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.md,
        vertical: IslamicSpacing.xs,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon, {
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return ListTile(
      leading: Icon(icon, color: isDark ? IslamicColors.darkLabelSecondary : IslamicColors.labelSecondary),
      title: Text(title, style: IslamicTextStyles.bodyLarge),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: IslamicColors.primaryGreen,
        trackColor: isDark ? IslamicColors.darkSeparator : IslamicColors.separator,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.md,
        vertical: IslamicSpacing.xs,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon, {
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return ListTile(
      leading: Icon(icon, color: isDark ? IslamicColors.darkLabelSecondary : IslamicColors.labelSecondary),
      title: Text(title, style: IslamicTextStyles.bodyLarge),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: IslamicTextStyles.bodySmall.copyWith(color: IslamicColors.labelTertiary)),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: IslamicColors.primaryGreen,
            inactiveColor: IslamicColors.secondaryGreen,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.md,
        vertical: IslamicSpacing.xs,
      ),
    );
  }

  String _getThemeLabel(SettingsProvider settings) {
    switch (settings.settings.themeMode) {
      case 1:
        return 'light_mode'.tr();
      case 2:
        return 'dark_mode'.tr();
      default:
        return 'system_theme'.tr();
    }
  }

  String _getMadhabLabel(SettingsProvider settings) {
    return settings.settings.madhab == 0 ? 'Shafi' : 'Hanafi';
  }

  String _getTranslationLanguageLabel(SettingsProvider settings) {
    switch (settings.settings.translationLanguage) {
      case 'en.sahih':
        return 'English (Sahih International)';
      case 'ar.ar':
        return 'Arabic';
      case 'fr.hamidullah':
        return 'French';
      case 'tr.diyanet':
        return 'Turkish';
      case 'ur.junagarhi':
        return 'Urdu';
      case 'id.indonesian':
        return 'Indonesian';
      default:
        return settings.settings.translationLanguage;
    }
  }

  void _showLanguagePicker(SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text('language'.tr(), style: IslamicTextStyles.titleMedium),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              settings.setLanguage('en');
              Navigator.pop(context);
            },
            child: Text('english'.tr()),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              settings.setLanguage('ar');
              Navigator.pop(context);
            },
            child: Text('arabic'.tr()),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
      ),
    );
  }

  void _showThemePicker(SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text('theme'.tr(), style: IslamicTextStyles.titleMedium),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              settings.setThemeMode(0);
              Navigator.pop(context);
            },
            child: Text('system_theme'.tr()),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              settings.setThemeMode(1);
              Navigator.pop(context);
            },
            child: Text('light_mode'.tr()),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              settings.setThemeMode(2);
              Navigator.pop(context);
            },
            child: Text('dark_mode'.tr()),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
      ),
    );
  }

  void _showCalculationMethodPicker(SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text('calculation_method'.tr(), style: IslamicTextStyles.titleMedium),
        actions: SettingsProvider.calculationMethods.map((method) {
          return CupertinoActionSheetAction(
            onPressed: () {
              settings.setCalculationMethod(method.id);
              Navigator.pop(context);
            },
            child: Text(method.name),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
      ),
    );
  }

  void _showMadhabPicker(SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text('madhab'.tr(), style: IslamicTextStyles.titleMedium),
        actions: SettingsProvider.madhabs.map((madhab) {
          return CupertinoActionSheetAction(
            onPressed: () {
              settings.setMadhab(madhab.id);
              Navigator.pop(context);
            },
            child: Text(madhab.name),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
      ),
    );
  }

  void _showTranslationPicker(SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text('translation_language'.tr(), style: IslamicTextStyles.titleMedium),
        actions: SettingsProvider.availableTranslations.map((lang) {
          return CupertinoActionSheetAction(
            onPressed: () {
              settings.setTranslationLanguage(lang);
              Navigator.pop(context);
            },
            child: Text(_getTranslationLabel(lang)),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
      ),
    );
  }

  String _getTranslationLabel(String code) {
    switch (code) {
      case 'en.sahih':
        return 'English (Sahih International)';
      case 'en.pickthall':
        return 'English (Pickthall)';
      case 'en.yusufali':
        return 'English (Yusuf Ali)';
      case 'en.shakir':
        return 'English (Shakir)';
      case 'ar.ar':
        return 'Arabic';
      case 'fr.hamidullah':
        return 'French (Hamidullah)';
      case 'tr.diyanet':
        return 'Turkish (Diyanet)';
      case 'ur.junagarhi':
        return 'Urdu (Junagarhi)';
      case 'id.indonesian':
        return 'Indonesian';
      default:
        return code;
    }
  }

  void _showReciterPicker(SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text('reciter'.tr(), style: IslamicTextStyles.titleMedium),
        actions: SettingsProvider.availableReciters.map((reciter) {
          return CupertinoActionSheetAction(
            onPressed: () {
              settings.setQuranReciter(reciter);
              Navigator.pop(context);
            },
            child: Text(_getReciterLabel(reciter)),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
      ),
    );
  }

  String _getReciterLabel(String reciter) {
    final names = {
      'ar.alafasy': 'Al-Afsay',
      'ar.abdurrahmaansudais': 'Abdul Rahman Al-Sudais',
      'ar.abdullahbasfar': 'Abdullah Basfar',
      'ar.husary': 'Mahmoud Khalil Al-Husary',
      'ar.husarymujawwad': 'Al-Husary (Mujawwad)',
      'ar.minshawi': 'Mohamed Siddiq Al-Minshawi',
      'ar.minshawimujawwad': 'Al-Minshawi (Mujawwad)',
      'ar.moayeq': 'Mohamed Moayeq',
      'ar.samir': 'Samir Al-Qurani',
      'ar.shuraim': 'Saud Al-Shuraim',
      'ar.sudais': 'Abdul Rahman Al-Sudais',
    };
    return names[reciter] ?? reciter;
  }

  void _showAdvanceMinutesPicker(SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text('advance_minutes'.tr(), style: IslamicTextStyles.titleMedium),
        actions: [0, 5, 10, 15, 30].map((min) {
          return CupertinoActionSheetAction(
            onPressed: () {
              settings.setNotificationAdvanceMinutes(min);
              Navigator.pop(context);
            },
            child: Text('$min ${min == 0 ? 'at_time'.tr() : 'minutes'.tr()}'),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
      ),
    );
  }

  void _clearCache() async {
    await StorageService.clearAll();
    context.read<QuranProvider>().clearSurahsCache();
    context.read<AzkarProvider>().initialize();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cache_cleared'.tr())),
      );
    }
  }

  void _resetAzkarProgress() {
    context.read<AzkarProvider>().resetDailyCompletions();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('azkar_reset'.tr())),
    );
  }

  void _exportData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('export_coming_soon'.tr())),
    );
  }

  void _importData() {
    // TODO: Implement data import
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('import_coming_soon'.tr())),
    );
  }
}
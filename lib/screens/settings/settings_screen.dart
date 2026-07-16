import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../constants/app_design.dart';
import '../../theme/islamic_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/azkar_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/hig.dart';

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
    final theme = IslamicTheme.of(context);

    return Scaffold(
      backgroundColor: theme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(theme),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildGeneralSection(settings, theme),
              _buildPrayerTimesSection(settings, theme),
              _buildQuranSection(settings, theme),
              _buildNotificationsSection(settings, theme),
              _buildAppearanceSection(settings, theme),
              _buildAdvancedSection(settings, theme),
              _buildAboutSection(settings, theme),
              const SizedBox(height: IslamicSpacing.xl),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(IslamicTheme theme) {
    return SliverAppBar(
      expandedHeight: 96,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: theme.background,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'settings'.tr(),
          style: IslamicTextStyles.titleLarge.copyWith(color: theme.textPrimary),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IslamicColors.primaryGreen.withValues(alpha: 0.12),
                IslamicColors.secondaryGreen.withValues(alpha: 0.04),
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
        kHIGMargin,
        IslamicSpacing.lg,
        kHIGMargin,
        IslamicSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: IslamicSpacing.sm),
          Text(
            title,
            style: IslamicTextStyles.titleMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(SettingsProvider settings, IslamicTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'general'.tr(),
          CupertinoIcons.gear,
          IslamicColors.primaryGreen,
        ),
        HIGGroup(children: [
          HIGTile(
            leading: Icon(CupertinoIcons.globe, color: theme.textSecondary),
            title: 'language'.tr(),
            subtitle: settings.locale.languageCode == 'ar'
                ? 'arabic'.tr()
                : 'english'.tr(),
            trailing: const Icon(CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey),
            onTap: () => _showLanguagePicker(settings),
          ),
          HIGTile(
            leading:
                Icon(CupertinoIcons.paintbrush, color: theme.textSecondary),
            title: 'theme'.tr(),
            subtitle: _getThemeLabel(settings),
            trailing: const Icon(CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey),
            onTap: () => _showThemePicker(settings),
          ),
        ]),
      ],
    );
  }

  Widget _buildPrayerTimesSection(
    SettingsProvider settings,
    IslamicTheme theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'prayer_times'.tr(),
          CupertinoIcons.clock,
          IslamicColors.prayerBlue,
        ),
        HIGGroup(children: [
          HIGTile(
            leading: Icon(CupertinoIcons.gear_alt, color: theme.textSecondary),
            title: 'calculation_method'.tr(),
            subtitle: _getCalculationMethodLabel(settings),
            trailing: const Icon(CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey),
            onTap: () => _showCalculationMethodPicker(settings),
          ),
          HIGTile(
            leading: Icon(CupertinoIcons.book, color: theme.textSecondary),
            title: 'madhab'.tr(),
            subtitle: _getMadhabLabel(settings),
            trailing: const Icon(CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey),
            onTap: () => _showMadhabPicker(settings),
          ),
        ]),
      ],
    );
  }

  Widget _buildQuranSection(SettingsProvider settings, IslamicTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'quran_settings'.tr(),
          CupertinoIcons.book,
          IslamicColors.quranGold,
        ),
        HIGGroup(children: [
          HIGSliderTile(
            leading:
                Icon(CupertinoIcons.textformat_size, color: theme.textSecondary),
            title: 'font_size'.tr(),
            subtitle: settings.settings.quranFontSize.toStringAsFixed(0),
            value: settings.settings.quranFontSize,
            min: 18,
            max: 40,
            divisions: 22,
            onChanged: (v) => settings.setQuranFontSize(v),
          ),
          HIGToggleTile(
            leading:
                Icon(CupertinoIcons.text_bubble, color: theme.textSecondary),
            title: 'show_translation'.tr(),
            value: settings.settings.showTranslation,
            onChanged: (v) => settings.setShowTranslation(v),
          ),
          HIGTile(
            leading: Icon(CupertinoIcons.globe, color: theme.textSecondary),
            title: 'translation_language'.tr(),
            subtitle: _getTranslationLanguageLabel(settings),
            trailing: const Icon(CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey),
            onTap: () => _showTranslationPicker(settings),
          ),
          HIGToggleTile(
            leading: Icon(CupertinoIcons.play, color: theme.textSecondary),
            title: 'auto_play_audio'.tr(),
            value: settings.settings.quranAudioAutoPlay,
            onChanged: (v) => settings.setQuranAudioAutoPlay(v),
          ),
          HIGTile(
            leading:
                Icon(CupertinoIcons.music_note, color: theme.textSecondary),
            title: 'reciter'.tr(),
            subtitle: _getReciterLabel(settings.settings.quranReciter),
            trailing: const Icon(CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey),
            onTap: () => _showReciterPicker(settings),
          ),
        ]),
      ],
    );
  }

  Widget _buildNotificationsSection(
    SettingsProvider settings,
    IslamicTheme theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'notifications'.tr(),
          CupertinoIcons.bell,
          IslamicColors.azkarRed,
        ),
        HIGGroup(children: [
          HIGToggleTile(
            leading:
                Icon(CupertinoIcons.bell_fill, color: theme.textSecondary),
            title: 'prayer_notifications'.tr(),
            value: settings.settings.notificationsEnabled,
            onChanged: (v) => settings.setNotificationsEnabled(v),
          ),
          if (settings.settings.notificationsEnabled) ...[
            HIGTile(
              leading: Icon(CupertinoIcons.timer, color: theme.textSecondary),
              title: 'advance_minutes'.tr(),
              subtitle: '${settings.settings.notificationAdvanceMinutes} min',
              trailing: const Icon(CupertinoIcons.chevron_right,
                  color: CupertinoColors.systemGrey),
              onTap: () => _showAdvanceMinutesPicker(settings),
            ),
            HIGToggleTile(
              leading:
                  Icon(CupertinoIcons.sunrise, color: theme.textSecondary),
              title: 'fajr_notification'.tr(),
              value: settings.settings.fajrNotification,
              onChanged: (v) => settings.setPrayerNotification('fajr', v),
            ),
            HIGToggleTile(
              leading: Icon(CupertinoIcons.sun_max, color: theme.textSecondary),
              title: 'dhuhr_notification'.tr(),
              value: settings.settings.dhuhrNotification,
              onChanged: (v) => settings.setPrayerNotification('dhuhr', v),
            ),
            HIGToggleTile(
              leading: Icon(CupertinoIcons.sun_min, color: theme.textSecondary),
              title: 'asr_notification'.tr(),
              value: settings.settings.asrNotification,
              onChanged: (v) => settings.setPrayerNotification('asr', v),
            ),
            HIGToggleTile(
              leading:
                  Icon(CupertinoIcons.sunset, color: theme.textSecondary),
              title: 'maghrib_notification'.tr(),
              value: settings.settings.maghribNotification,
              onChanged: (v) => settings.setPrayerNotification('maghrib', v),
            ),
            HIGToggleTile(
              leading: Icon(CupertinoIcons.moon, color: theme.textSecondary),
              title: 'isha_notification'.tr(),
              value: settings.settings.ishaNotification,
              onChanged: (v) => settings.setPrayerNotification('isha', v),
            ),
          ],
        ]),
      ],
    );
  }

  Widget _buildAppearanceSection(SettingsProvider settings, IslamicTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'appearance'.tr(),
          CupertinoIcons.paintbrush,
          IslamicColors.quranGold,
        ),
        HIGGroup(children: [
          HIGToggleTile(
            leading:
                Icon(CupertinoIcons.hand_raised, color: theme.textSecondary),
            title: 'haptic_feedback'.tr(),
            value: settings.settings.hapticFeedback,
            onChanged: (v) => settings.setHapticFeedback(v),
          ),
          HIGToggleTile(
            leading:
                Icon(CupertinoIcons.arrow_up_down, color: theme.textSecondary),
            title: 'reduce_motion'.tr(),
            value: settings.settings.reduceMotion,
            onChanged: (v) => settings.setReduceMotion(v),
          ),
        ]),
      ],
    );
  }

  Widget _buildAdvancedSection(SettingsProvider settings, IslamicTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'advanced'.tr(),
          CupertinoIcons.wrench,
          IslamicColors.qiblaOrange,
        ),
        HIGGroup(children: [
          HIGTile(
            leading: Icon(CupertinoIcons.trash, color: theme.textSecondary),
            title: 'clear_cache'.tr(),
            onTap: () => _clearCache(),
          ),
          HIGTile(
            leading: Icon(CupertinoIcons.arrow_counterclockwise,
                color: theme.textSecondary),
            title: 'reset_azkar_progress'.tr(),
            onTap: () => _resetAzkarProgress(),
          ),
          HIGTile(
            leading: Icon(CupertinoIcons.square_arrow_up,
                color: theme.textSecondary),
            title: 'export_data'.tr(),
            onTap: () => _exportData(),
          ),
          HIGTile(
            leading: Icon(CupertinoIcons.square_arrow_down,
                color: theme.textSecondary),
            title: 'import_data'.tr(),
            onTap: () => _importData(),
          ),
        ]),
      ],
    );
  }

  Widget _buildAboutSection(SettingsProvider settings, IslamicTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'about'.tr(),
          CupertinoIcons.info,
          theme.textSecondary,
        ),
        HIGGroup(children: [
          HIGTile(
            leading: Icon(CupertinoIcons.tag, color: theme.textSecondary),
            title: 'version'.tr(),
            subtitle: '1.0.0',
            showChevron: false,
          ),
          HIGTile(
            leading:
                Icon(CupertinoIcons.doc_text, color: theme.textSecondary),
            title: 'privacy_policy'.tr(),
            onTap: () {},
          ),
          HIGTile(
            leading: Icon(CupertinoIcons.doc_text_fill,
                color: theme.textSecondary),
            title: 'terms_of_service'.tr(),
            onTap: () {},
          ),
          HIGTile(
            leading: Icon(CupertinoIcons.star, color: theme.textSecondary),
            title: 'rate_app'.tr(),
            onTap: () {},
          ),
          HIGTile(
            leading: Icon(CupertinoIcons.share, color: theme.textSecondary),
            title: 'share_app'.tr(),
            onTap: () {},
          ),
        ]),
      ],
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
    return settings.settings.madhab == 0 ? 'shafi'.tr() : 'hanafi'.tr();
  }

  String _getCalculationMethodLabel(SettingsProvider settings) {
    final method = SettingsProvider.calculationMethods.firstWhere(
      (m) => m.id == settings.settings.calculationMethod,
      orElse: () => SettingsProvider.calculationMethods.first,
    );
    return '${method.id} · ${method.name}';
  }

  String _getTranslationLanguageLabel(SettingsProvider settings) {
    switch (settings.settings.translationLanguage) {
      case 'en.sahih':
        return 'english_sahih'.tr();
      case 'ar.ar':
        return 'arabic'.tr();
      case 'fr.hamidullah':
        return 'french'.tr();
      case 'tr.diyanet':
        return 'turkish'.tr();
      case 'ur.junagarhi':
        return 'urdu'.tr();
      case 'id.indonesian':
        return 'indonesian'.tr();
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
        title: Text('calculation_method'.tr(),
            style: IslamicTextStyles.titleMedium),
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
        title: Text('translation_language'.tr(),
            style: IslamicTextStyles.titleMedium),
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
        return 'english_sahih'.tr();
      case 'en.pickthall':
        return 'english_pickthall'.tr();
      case 'en.yusufali':
        return 'english_yusufali'.tr();
      case 'en.shakir':
        return 'english_shakir'.tr();
      case 'ar.ar':
        return 'arabic'.tr();
      case 'fr.hamidullah':
        return 'french'.tr();
      case 'tr.diyanet':
        return 'turkish'.tr();
      case 'ur.junagarhi':
        return 'urdu'.tr();
      case 'id.indonesian':
        return 'indonesian'.tr();
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
        title:
            Text('advance_minutes'.tr(), style: IslamicTextStyles.titleMedium),
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
    if (!mounted) return;
    context.read<QuranProvider>().clearSurahsCache();
    context.read<AzkarProvider>().initialize();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('cache_cleared'.tr())),
    );
  }

  void _resetAzkarProgress() {
    context.read<AzkarProvider>().resetDailyCompletions();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('azkar_reset'.tr())),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('export_coming_soon'.tr())),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('import_coming_soon'.tr())),
    );
  }
}

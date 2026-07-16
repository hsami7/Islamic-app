import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../constants/app_design.dart';
import '../../theme/islamic_theme.dart';
import '../../models/surah.dart';
import '../../models/ayah.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/storage_service.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final quranProvider = context.watch<QuranProvider>();
    final isArabic = settings.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: settings.isDarkMode
          ? IslamicColors.darkSystemGroupedBackground
          : IslamicColors.systemGroupedBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(isArabic),
          _buildSearchBar(isArabic),
          if (quranProvider.isLoadingSurahs)
            _buildLoadingState()
          else if (quranProvider.surahsError != null)
            _buildErrorState(quranProvider.surahsError!, quranProvider)
          else
            _buildSurahList(quranProvider, isArabic),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isArabic) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('quran'.tr(), style: IslamicTextStyles.titleLarge),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IslamicColors.primaryGreen.withValues(alpha: 0.1),
                IslamicColors.secondaryGreen.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.search),
          onPressed: () => setState(() => _showSearch = true),
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.bookmark_fill),
          onPressed: () => _showBookmarks(),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isArabic) {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: IslamicDurations.fast,
        height: _showSearch ? 56 : 0,
        child: _showSearch
            ? Padding(
                padding: const EdgeInsets.all(IslamicSpacing.md),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'search_quran'.tr(),
                    prefixIcon: const Icon(CupertinoIcons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(CupertinoIcons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _showSearch = false;
                          _searchQuery = '';
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: IslamicColors.primaryGreen),
            const SizedBox(height: IslamicSpacing.md),
            Text('loading'.tr(), style: IslamicTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, QuranProvider provider) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(IslamicSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 48,
                color: IslamicColors.azkarRed,
              ),
              const SizedBox(height: IslamicSpacing.md),
              Text(
                'error'.tr(),
                style: IslamicTextStyles.headlineSmall.copyWith(color: IslamicColors.azkarRed),
              ),
              const SizedBox(height: IslamicSpacing.sm),
              Text(
                error,
                style: IslamicTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IslamicSpacing.lg),
              ElevatedButton.icon(
                onPressed: () => provider.loadSurahs(forceRefresh: true),
                icon: const Icon(CupertinoIcons.refresh),
                label: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahList(QuranProvider provider, bool isArabic) {
    final surahs = _searchQuery.isEmpty
        ? provider.surahs
        : provider.searchSurahs(_searchQuery);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final surah = surahs[index];
          return _buildSurahCard(surah, provider, isArabic);
        },
        childCount: surahs.length,
      ),
    );
  }

  Widget _buildSurahCard(Surah surah, QuranProvider provider, bool isArabic) {
    final isBookmarked = provider.quranBookmarks
        .any((b) => b.surahNumber == surah.number && b.ayahNumber == 0);
    final theme = IslamicTheme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.md,
        vertical: IslamicSpacing.xs,
      ),
      color: theme.card,
      child: InkWell(
        onTap: () => _showSurahDetail(surah, provider),
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(IslamicSpacing.md),
          child: Row(
            children: [
              // Surah number circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      IslamicColors.primaryGreen,
                      IslamicColors.primaryGreenLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(IslamicRadius.md),
                ),
                child: Center(
                  child: Text(
                    surah.number.toString(),
                    style: IslamicTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: IslamicSpacing.md),

              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Arabic name
                    Text(
                      surah.name,
                      style: IslamicTextStyles.arabicMedium.copyWith(
                        fontSize: 22,
                        color: theme.textPrimary,
                      ),
                      textDirection: ui.TextDirection.rtl,
                    ),
                    const SizedBox(height: 2),
                    // English name
                    Text(
                      surah.englishName,
                      style: IslamicTextStyles.bodyMedium.copyWith(
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Translation
                    Text(
                      surah.englishNameTranslation,
                      style: IslamicTextStyles.bodySmall.copyWith(
                        color: theme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats and actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Ayah count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: IslamicSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: IslamicColors.secondaryGreen,
                      borderRadius: BorderRadius.circular(IslamicRadius.pill),
                    ),
                    child: Text(
                      '${surah.numberOfAyahs} ${'ayah'.tr()}',
                      style: IslamicTextStyles.labelSmall.copyWith(
                        color: IslamicColors.primaryGreenDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: IslamicSpacing.xs),
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: IslamicSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: surah.revelationType.toLowerCase() == 'meccan'
                          ? IslamicColors.prayerBlue.withValues(alpha: 0.1)
                          : IslamicColors.qiblaOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(IslamicRadius.pill),
                    ),
                    child: Text(
                      surah.revelationType,
                      style: IslamicTextStyles.labelSmall.copyWith(
                        color: surah.revelationType.toLowerCase() == 'meccan'
                            ? IslamicColors.prayerBlue
                            : IslamicColors.qiblaOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: IslamicSpacing.sm),
                  // Bookmark
                  IconButton(
                    icon: Icon(
                      isBookmarked
                          ? CupertinoIcons.bookmark_fill
                          : CupertinoIcons.bookmark,
                      color: isBookmarked ? IslamicColors.accentGold : IslamicColors.labelTertiary,
                      size: 22,
                    ),
                    onPressed: () => _toggleSurahBookmark(surah, provider),
                    tooltip: isBookmarked ? 'remove_bookmark'.tr() : 'add_bookmark'.tr(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSurahDetail(Surah surah, QuranProvider provider) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => SurahDetailScreen(surah: surah),
      ),
    );
  }

  void _showBookmarks() {
    final provider = context.read<QuranProvider>();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => _BookmarksModal(provider: provider),
    );
  }

  void _toggleSurahBookmark(Surah surah, QuranProvider provider) {
    if (provider.isBookmarked(surah.number, 0)) {
      provider.removeQuranBookmark(surah.number, 0);
    } else {
      provider.addQuranBookmark(surahNumber: surah.number, ayahNumber: 0);
    }
  }
}

class _BookmarksModal extends StatelessWidget {
  final QuranProvider provider;

  const _BookmarksModal({required this.provider});

  @override
  Widget build(BuildContext context) {
    final bookmarks = provider.quranBookmarks;

    return CupertinoActionSheet(
      title: Text('bookmarks'.tr(), style: IslamicTextStyles.titleMedium),
      message: bookmarks.isEmpty
          ? Text('no_bookmarks'.tr(), style: IslamicTextStyles.bodyMedium)
          : null,
      actions: bookmarks.map((b) {
        return CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            provider.loadSurahAyahs(b.surahNumber).then((ayahs) {
              if (ayahs.isNotEmpty && context.mounted) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => SurahDetailScreen(
                      surah: provider.surahs.firstWhere((s) => s.number == b.surahNumber),
                      initialAyah: b.ayahNumber,
                    ),
                  ),
                );
              }
            });
          },
          child: Text(
            'Surah ${b.surahNumber} - Ayah ${b.ayahNumber}',
            style: IslamicTextStyles.bodyMedium,
          ),
        );
      }).toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: Text('cancel'.tr(), style: IslamicTextStyles.labelLarge),
      ),
    );
  }
}

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyah;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.initialAyah,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Ayah> _ayahs = [];
  bool _isLoading = true;
  String? _error;
  int? _playingAyah;
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAyahs();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_ayahs.isEmpty) return;
    // Approximate the centered ayah index from scroll offset + viewport.
    final offset = _scrollController.offset + 200; // bias toward center
    const itemApprox = 160.0; // avg ayah card height
    final idx = (offset / itemApprox).floor().clamp(0, _ayahs.length - 1);
    final ayahNo = _ayahs[idx].numberInSurah;
    _currentIndex = idx;
    if (ayahNo != _lastRecorded) {
      _lastRecorded = ayahNo;
      StorageService.saveReadingProgress(widget.surah.number, ayahNo);
    }
  }

  void _goToAyah(int index) {
    if (_ayahs.isEmpty) return;
    final target = index.clamp(0, _ayahs.length - 1);
    if (target == _currentIndex) return;
    setState(() => _currentIndex = target);
    // Average ayah card height including padding (~200px).
    const itemHeight = 200.0;
    _scrollController.animateTo(
      target * itemHeight,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  int _lastRecorded = 0;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAyahs() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<QuranProvider>();
      _ayahs = await provider.loadSurahAyahs(widget.surah.number);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _playAyah(Ayah ayah) async {
    // Record progress when the user listens to an ayah.
    StorageService.saveReadingProgress(widget.surah.number, ayah.numberInSurah);
    if (_playingAyah == ayah.numberInSurah) {
      await _audioPlayer.pause();
      setState(() => _playingAyah = null);
      return;
    }

    try {
      await _audioPlayer.play(UrlSource(ayah.audioUrl));
      setState(() => _playingAyah = ayah.numberInSurah);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isArabic = settings.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name, style: IslamicTextStyles.arabicMedium),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(IslamicSpacing.md),
                      itemCount: _ayahs.length,
                      itemBuilder: (context, index) {
                        final ayah = _ayahs[index];
                        return _buildAyahItem(ayah, isArabic, settings);
                      },
                    ),
          // Tap zones: left = next ayah, right = previous ayah.
          if (!_isLoading && _error == null)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _goToAyah(_currentIndex + 1),
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _goToAyah(_currentIndex - 1),
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAyahItem(Ayah ayah, bool isArabic, SettingsProvider settings) {
    final isPlaying = _playingAyah == ayah.numberInSurah;
    final theme = IslamicTheme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.md),
      color: theme.card,
      child: Padding(
        padding: const EdgeInsets.all(IslamicSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ayah number
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: IslamicSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: IslamicColors.secondaryGreen,
                    borderRadius: BorderRadius.circular(IslamicRadius.pill),
                  ),
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: IslamicTextStyles.labelSmall.copyWith(
                      color: IslamicColors.primaryGreenDark,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                    color: theme.accent,
                  ),
                  onPressed: () => _playAyah(ayah),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.bookmark),
                  color: theme.textTertiary,
                  onPressed: () => _toggleBookmark(ayah),
                ),
              ],
            ),
            const SizedBox(height: IslamicSpacing.md),

            // Arabic text
            Text(
              ayah.textArabic,
              style: IslamicTextStyles.quranAyah.copyWith(
                fontSize: settings.settings.quranFontSize,
                color: theme.textPrimary,
              ),
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.center,
            ),

            // Translation
            if (settings.settings.showTranslation && ayah.translation.isNotEmpty) ...[
              const SizedBox(height: IslamicSpacing.md),
              Divider(color: theme.separator),
              const SizedBox(height: IslamicSpacing.sm),
              Text(
                ayah.translation,
                style: IslamicTextStyles.quranTranslation.copyWith(
                  color: theme.textSecondary,
                ),
                textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleBookmark(Ayah ayah) {
    final provider = context.read<QuranProvider>();
    if (provider.isBookmarked(widget.surah.number, ayah.numberInSurah)) {
      provider.removeQuranBookmark(widget.surah.number, ayah.numberInSurah);
    } else {
      provider.addQuranBookmark(
        surahNumber: widget.surah.number,
        ayahNumber: ayah.numberInSurah,
      );
    }
  }
}

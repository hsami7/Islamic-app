import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../constants/app_design.dart';
import '../../theme/islamic_theme.dart';
import '../../widgets/hig.dart';
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
    final theme = IslamicTheme.of(context);

    return HIGScaffold(
      title: 'quran',
      onRefresh: () => quranProvider.loadSurahs(forceRefresh: true),
      slivers: [
        _buildActions(theme),
        if (_showSearch) _buildSearchBar(isArabic),
        if (quranProvider.isLoadingSurahs)
          _buildLoadingState()
        else if (quranProvider.surahsError != null)
          _buildErrorState(quranProvider.surahsError!, quranProvider)
        else
          _buildSurahList(quranProvider, isArabic, theme),
      ],
    );
  }

  Widget _buildActions(IslamicTheme theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kHIGMargin,
          vertical: IslamicSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => setState(() => _showSearch = !_showSearch),
              child: Icon(
                CupertinoIcons.search,
                color: theme.accent,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showBookmarks(),
              child: Icon(
                CupertinoIcons.bookmark_fill,
                color: theme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isArabic) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kHIGMargin,
          vertical: IslamicSpacing.xs,
        ),
        child: CupertinoSearchTextField(
          controller: _searchController,
          autofocus: true,
          placeholder: 'search_quran'.tr(),
          onChanged: (value) => setState(() => _searchQuery = value),
          onSuffixTap: () {
            _searchController.clear();
            setState(() => _searchQuery = '');
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = IslamicTheme.of(context);
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoActivityIndicator(color: theme.accent),
            const SizedBox(height: IslamicSpacing.md),
            Text('loading'.tr(), style: IslamicTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, QuranProvider provider) {
    final theme = IslamicTheme.of(context);
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
                color: theme.red,
              ),
              const SizedBox(height: IslamicSpacing.md),
              Text(
                'error'.tr(),
                style: IslamicTextStyles.headlineSmall.copyWith(color: theme.red),
              ),
              const SizedBox(height: IslamicSpacing.sm),
              Text(
                error,
                style: IslamicTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IslamicSpacing.lg),
              CupertinoButton.filled(
                onPressed: () => provider.loadSurahs(forceRefresh: true),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahList(
    QuranProvider provider,
    bool isArabic,
    IslamicTheme theme,
  ) {
    final surahs = _searchQuery.isEmpty
        ? provider.surahs
        : provider.searchSurahs(_searchQuery);

    if (surahs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(IslamicSpacing.lg),
          child: Center(
            child: Text(
              'no_results'.tr(),
              style: IslamicTextStyles.bodyMedium
                  .copyWith(color: theme.textSecondary),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final surah = surahs[index];
          return _buildSurahTile(surah, provider, isArabic, theme);
        },
        childCount: surahs.length,
      ),
    );
  }

  Widget _buildSurahTile(
    Surah surah,
    QuranProvider provider,
    bool isArabic,
    IslamicTheme theme,
  ) {
    final isBookmarked = provider.quranBookmarks
        .any((b) => b.surahNumber == surah.number && b.ayahNumber == 0);

    const badgeRadius = IslamicRadius.sm + 2.0;

    return HIGGroup(
      margin: const EdgeInsets.symmetric(
        horizontal: kHIGMargin,
        vertical: IslamicSpacing.xs,
      ),
      children: [
        HIGTile(
          onTap: () => _showSurahDetail(surah, provider),
          icon: CupertinoIcons.book_fill,
          iconColor: theme.accent,
          label: surah.englishName,
          subtitleWidget: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Row(
              children: [
                Text(
                  surah.name,
                  style: IslamicTextStyles.arabicMedium.copyWith(
                    fontSize: 20,
                    color: theme.textPrimary,
                  ),
                  textDirection: ui.TextDirection.rtl,
                ),
                const SizedBox(width: IslamicSpacing.sm),
                Expanded(
                  child: Text(
                    surah.englishNameTranslation,
                    style: IslamicTextStyles.bodySmall
                        .copyWith(color: theme.textTertiary),
                  ),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Surah number chip
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.accentSoft,
                  borderRadius: BorderRadius.circular(badgeRadius),
                ),
                child: Center(
                  child: Text(
                    surah.number.toString(),
                    style: IslamicTextStyles.titleSmall.copyWith(
                      color: theme.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: IslamicSpacing.sm),
              // Bookmark toggle
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _toggleSurahBookmark(surah, provider),
                child: Icon(
                  isBookmarked
                      ? CupertinoIcons.bookmark_fill
                      : CupertinoIcons.bookmark,
                  color: isBookmarked ? theme.gold : theme.textTertiary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ],
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
    final theme = IslamicTheme.of(context);

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
                      surah: provider.surahs
                          .firstWhere((s) => s.number == b.surahNumber),
                      initialAyah: b.ayahNumber,
                    ),
                  ),
                );
              }
            });
          },
          child: Text(
            'Surah ${b.surahNumber} - Ayah ${b.ayahNumber}',
            style: IslamicTextStyles.bodyMedium
                .copyWith(color: theme.textPrimary),
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
  int _lastRecorded = 0;

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
      if (widget.initialAyah != null && _ayahs.isNotEmpty) {
        final idx = _ayahs.indexWhere(
          (a) => a.numberInSurah == widget.initialAyah,
        );
        if (idx >= 0) {
          _currentIndex = idx;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _goToAyah(idx);
          });
        }
      }
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
    final theme = IslamicTheme.of(context);

    return HIGScaffold(
      title: widget.surah.name,
      useScrollView: false,
      body: Stack(
        children: [
          _isLoading
              ? Center(
                  child: CupertinoActivityIndicator(color: theme.accent),
                )
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(IslamicSpacing.lg),
                        child: Text(
                          _error!,
                          style: IslamicTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: kHIGMargin,
                        vertical: IslamicSpacing.md,
                      ),
                      itemCount: _ayahs.length,
                      itemBuilder: (context, index) {
                        final ayah = _ayahs[index];
                        return _buildAyahCard(ayah, isArabic, settings, theme);
                      },
                    ),

          // Tap zones: left half = next ayah, right half = previous ayah.
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

          // Position pill (current ayah / total).
          if (!_isLoading && _error == null && _ayahs.isNotEmpty)
            Positioned(
              top: IslamicSpacing.sm,
              left: kHIGMargin,
              right: kHIGMargin,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: IslamicSpacing.md,
                      vertical: IslamicSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.card,
                      borderRadius: BorderRadius.circular(IslamicRadius.pill),
                      boxShadow: IslamicShadows.card,
                    ),
                    child: Text(
                      '${_ayahs[_currentIndex].numberInSurah} / ${_ayahs.length}',
                      style: IslamicTextStyles.labelMedium.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAyahCard(
    Ayah ayah,
    bool isArabic,
    SettingsProvider settings,
    IslamicTheme theme,
  ) {
    final isPlaying = _playingAyah == ayah.numberInSurah;
    final isCurrent = _ayahs[_currentIndex] == ayah;

    return HIGCard(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.md),
      color: isCurrent ? theme.accentSoft : theme.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ayah number + actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: IslamicSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.accentSoft,
                  borderRadius: BorderRadius.circular(IslamicRadius.pill),
                ),
                child: Text(
                  '${ayah.numberInSurah}',
                  style: IslamicTextStyles.labelSmall.copyWith(
                    color: theme.accent,
                  ),
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _playAyah(ayah),
                child: Icon(
                  isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                  color: theme.accent,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _toggleBookmark(ayah),
                child: Icon(
                  _isBookmarked(ayah)
                      ? CupertinoIcons.bookmark_fill
                      : CupertinoIcons.bookmark,
                  color: _isBookmarked(ayah) ? theme.gold : theme.textTertiary,
                ),
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
            Divider(color: theme.separator, height: 1, thickness: 0.5),
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
    );
  }

  bool _isBookmarked(Ayah ayah) {
    final provider = context.read<QuranProvider>();
    return provider.isBookmarked(widget.surah.number, ayah.numberInSurah);
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

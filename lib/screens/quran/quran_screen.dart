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
import '../../utils/tajweed.dart';
import '../../models/reciter.dart';
import '../../utils/numerals.dart';

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

  // Playback state
  bool _repeat = false;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      if (_repeat && _playingAyah != null) {
        final ayah = _ayahs.firstWhere(
          (a) => a.numberInSurah == _playingAyah,
          orElse: () => _ayahs.first,
        );
        _playAyah(ayah);
      } else {
        setState(() => _playingAyah = null);
      }
    });
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
    if (target == _currentIndex && _scrollController.hasClients) return;
    setState(() => _currentIndex = target);
    // Average ayah card height including padding (~200px).
    const itemHeight = 200.0;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        target * itemHeight,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
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

  Reciter get _selectedReciter {
    final provider = context.read<QuranProvider>();
    return provider.selectedReciter;
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
      final provider = context.read<QuranProvider>();
      await _audioPlayer.setSourceUrl(provider.getAyahAudioUrl(ayah.numberInSurah));
      await _audioPlayer.setPlaybackRate(_playbackSpeed);
      await _audioPlayer.resume();
      setState(() => _playingAyah = ayah.numberInSurah);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _setReciter(Reciter reciter) async {
    final provider = context.read<QuranProvider>();
    await provider.setReciter(reciter);
    if (_playingAyah != null) {
      final ayah = _ayahs.firstWhere(
        (a) => a.numberInSurah == _playingAyah,
        orElse: () => _ayahs.first,
      );
      await _audioPlayer.stop();
      await _playAyah(ayah);
    }
    if (mounted) setState(() {});
  }

  void _cycleSpeed() {
    const speeds = [1.0, 1.25, 1.5, 2.0];
    final idx = speeds.indexWhere((s) => s == _playbackSpeed);
    final next = speeds[(idx + 1) % speeds.length];
    setState(() => _playbackSpeed = next);
    _audioPlayer.setPlaybackRate(next);
  }

  void _showReciterSheet(IslamicTheme theme) {
    final provider = context.read<QuranProvider>();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('reciter'.tr()),
        message: Text('choose_reciter'.tr()),
        actions: Reciter.all
            .map(
              (r) => CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _setReciter(r);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (r.id == provider.selectedReciter.id) // needed
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          CupertinoIcons.check_mark,
                          size: 16,
                          color: IslamicColors.primaryGreen,
                        ),
                      ),
                    Text(r.nameAr),
                  ],
                ),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('cancel'.tr()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isArabic = settings.locale.languageCode == 'ar';
    final theme = IslamicTheme.of(context);
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? IslamicColors.darkBeigeSurface : IslamicColors.beigeSurface,
      appBar: AppBar(
        backgroundColor:
            isDark ? IslamicColors.darkBeigeSurface : IslamicColors.beigeSurface,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            CupertinoIcons.back,
            color: IslamicColors.primaryGreen,
          ),
        ),
        title: Text(
          widget.surah.name,
          style: IslamicTextStyles.headlineMedium.copyWith(
            color: theme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header: الجزء N | صفحة N
          if (!_isLoading && _error == null && _ayahs.isNotEmpty)
            _buildHeader(theme, isDark),

          // Ayah list (white centered card)
          Expanded(
            child: _isLoading
                ? Center(
                    child: CupertinoActivityIndicator(
                      color: IslamicColors.primaryGreen,
                    ),
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
                          return _buildAyahCard(
                            ayah,
                            isArabic,
                            settings,
                            theme,
                            isDark,
                          );
                        },
                      ),
          ),

          // Footer (Surah | Verse X/Y)
          if (!_isLoading && _error == null && _ayahs.isNotEmpty)
            _SurahFooter(
              surah: widget.surah,
              currentAyah: _ayahs[_currentIndex].numberInSurah,
              total: widget.surah.numberOfAyahs,
              theme: theme,
            ),

          // Playback bar
          if (!_isLoading && _error == null && _ayahs.isNotEmpty)
            _buildPlaybackBar(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(IslamicTheme theme, bool isDark) {
    final first = _ayahs.first;
    final juz = toLatinDigits(first.juz.toString());
    final page = toLatinDigits(first.page.toString());
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: IslamicSpacing.sm,
        horizontal: kHIGMargin,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _infoChip('الجزء', juz, theme, isDark),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: IslamicSpacing.md),
            child: Text(
              '|',
              style: IslamicTextStyles.bodyLarge.copyWith(
                color: theme.textTertiary,
              ),
            ),
          ),
          _infoChip('صفحة', page, theme, isDark),
        ],
      ),
    );
  }

  Widget _infoChip(
    String label,
    String value,
    IslamicTheme theme,
    bool isDark,
  ) {
    return Row(
      children: [
        Text(
          '$label ',
          style: IslamicTextStyles.labelMedium.copyWith(
            color: theme.textSecondary,
          ),
        ),
        Text(
          value,
          style: IslamicTextStyles.labelMedium.copyWith(
            color: IslamicColors.primaryGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackBar(IslamicTheme theme, bool isDark) {
    final reciter = _selectedReciter;
    final hasCurrent = _playingAyah != null;
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kHIGMargin,
        vertical: IslamicSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? IslamicColors.darkSystemBackground : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(IslamicRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.separator,
                valueColor: AlwaysStoppedAnimation<Color>(
                  IslamicColors.primaryGreen,
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: IslamicSpacing.sm),
            Row(
              children: [
                // Reciter picker
                Expanded(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showReciterSheet(theme),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.person_fill,
                          size: 16,
                          color: theme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            reciter.nameAr,
                            style: IslamicTextStyles.labelSmall.copyWith(
                              color: theme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Speed (1x)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: IslamicSpacing.sm),
                  onPressed: _cycleSpeed,
                  child: Text(
                    '${_playbackSpeed.toStringAsFixed(_playbackSpeed == 1.0 ? 0 : 2)}x',
                    style: IslamicTextStyles.labelSmall.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ),

                // Play / pause (current ayah)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: IslamicSpacing.sm),
                  onPressed: () {
                    if (_playingAyah != null) {
                      _audioPlayer.pause();
                      setState(() => _playingAyah = null);
                    } else {
                      final ayah = _ayahs[_currentIndex];
                      _playAyah(ayah);
                    }
                  },
                  child: Icon(
                    hasCurrent
                        ? CupertinoIcons.pause_fill
                        : CupertinoIcons.play_fill,
                    color: IslamicColors.primaryGreen,
                    size: 28,
                  ),
                ),

                // Repeat toggle
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: IslamicSpacing.sm),
                  onPressed: () => setState(() => _repeat = !_repeat),
                  child: Icon(
                    _repeat
                        ? CupertinoIcons.repeat
                        : CupertinoIcons.repeat,
                    color: _repeat
                        ? IslamicColors.primaryGreen
                        : theme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahCard(
    Ayah ayah,
    bool isArabic,
    SettingsProvider settings,
    IslamicTheme theme,
    bool isDark,
  ) {
    final isPlaying = _playingAyah == ayah.numberInSurah;
    final isCurrent = _ayahs[_currentIndex] == ayah;

    final baseStyle = IslamicTextStyles.quranAyah.copyWith(
      fontSize: settings.settings.quranFontSize,
      color: Colors.black87,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: isCurrent
            ? Border.all(color: IslamicColors.primaryGreen, width: 1.5)
            : null,
      ),
      padding: const EdgeInsets.all(IslamicSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ayah number pill + actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: IslamicSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: IslamicColors.secondarySystemBackground,
                  borderRadius: BorderRadius.circular(IslamicRadius.pill),
                ),
                child: Text(
                  toLatinDigits(ayah.numberInSurah.toString()),
                  style: IslamicTextStyles.labelSmall.copyWith(
                    color: IslamicColors.primaryGreen,
                  ),
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _playAyah(ayah),
                child: Icon(
                  isPlaying
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  color: IslamicColors.primaryGreen,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _toggleBookmark(ayah),
                child: Icon(
                  _isBookmarked(ayah)
                      ? CupertinoIcons.bookmark_fill
                      : CupertinoIcons.bookmark,
                  color: _isBookmarked(ayah)
                      ? IslamicColors.accentGold
                      : theme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: IslamicSpacing.md),

          // Arabic Tajweed text (centered white card)
          RichText(
            textAlign: TextAlign.center,
            textDirection: ui.TextDirection.rtl,
            text: TextSpan(
              children: parseTajweed(
                ayah.textTajweed.isNotEmpty
                    ? ayah.textTajweed
                    : ayah.textArabic,
                baseStyle,
              ),
            ),
          ),

          // Translation
          if (settings.settings.showTranslation && ayah.translation.isNotEmpty) ...[
            const SizedBox(height: IslamicSpacing.md),
            Divider(
              color: theme.separator,
              height: 1,
              thickness: 0.5,
            ),
            const SizedBox(height: IslamicSpacing.sm),
            Text(
              ayah.translation,
              style: IslamicTextStyles.quranTranslation.copyWith(
                color: theme.textSecondary,
              ),
              textDirection:
                  isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
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
    setState(() {});
  }
}

// Footer (Surah | Verse X/Y) rendered as a small persistent strip above the
// playback bar.
class _SurahFooter extends StatelessWidget {
  final Surah surah;
  final int currentAyah;
  final int total;
  final IslamicTheme theme;

  const _SurahFooter({
    required this.surah,
    required this.currentAyah,
    required this.total,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: IslamicSpacing.xs,
        horizontal: kHIGMargin,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            surah.name,
            style: IslamicTextStyles.labelSmall.copyWith(
              color: theme.textSecondary,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: IslamicSpacing.sm),
            child: Text(
              '|',
              style: IslamicTextStyles.labelSmall.copyWith(
                color: theme.textTertiary,
              ),
            ),
          ),
          Text(
            '${toLatinDigits(currentAyah.toString())} / ${toLatinDigits(total.toString())}',
            style: IslamicTextStyles.labelSmall.copyWith(
              color: IslamicColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

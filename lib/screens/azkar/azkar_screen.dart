import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../constants/app_design.dart';
import '../../theme/islamic_theme.dart';
import '../../widgets/hig.dart';
import '../../models/azkar.dart';
import '../../providers/azkar_provider.dart';
import '../../providers/settings_provider.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  void _openAzkarCounter(Azkar azkar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AzkarCounterSheet(
        azkar: azkar,
        initialCount: 0,
        onComplete: (count) {
          if (count >= azkar.count) {
            context.read<AzkarProvider>().incrementCompletion(azkar.id);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final azkarProvider = context.watch<AzkarProvider>();
    final settings = context.watch<SettingsProvider>();

    return HIGScaffold(
      title: 'azkar',
      onRefresh: () => azkarProvider.initialize(),
      slivers: [
        _buildCategoriesGroup(azkarProvider, settings),
        SliverToBoxAdapter(child: _buildFavoritesGroup(azkarProvider, settings)),
      ],
    );
  }

  Widget _buildCategoriesGroup(AzkarProvider provider, SettingsProvider settings) {
    if (provider.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(IslamicSpacing.lg),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final List<Widget> tiles = [];
    for (final category in provider.categories) {
      tiles.add(
        HIGTile(
          icon: CupertinoIcons.sparkles,
          iconColor: IslamicTheme.of(context).red,
          label: settings.locale.languageCode == 'ar'
              ? category.nameArabic
              : category.name,
          subtitleWidget: Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    settings.locale.languageCode == 'ar'
                        ? category.descriptionArabic
                        : category.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          trailing: _CategoryProgress(
            count: category.azkar.length,
          ),
          onTap: () => _showCategoryAzkar(category, provider, settings),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: HIGGroup(
        header: 'categories',
        children: tiles,
      ),
    );
  }

  Widget _buildFavoritesGroup(AzkarProvider provider, SettingsProvider settings) {
    final favorites = provider.favoriteAzkar;

    if (favorites.isEmpty) {
      return HIGCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.heart,
              size: 48,
              color: IslamicTheme.of(context).textTertiary,
            ),
            const SizedBox(height: IslamicSpacing.md),
            Text(
              'no_favorites'.tr(),
              style: IslamicTextStyles.bodyMedium.copyWith(
                color: IslamicTheme.of(context).textPrimary,
              ),
            ),
            const SizedBox(height: IslamicSpacing.sm),
            Text(
              'add_favorites_hint'.tr(),
              style: IslamicTextStyles.bodySmall.copyWith(
                color: IslamicTheme.of(context).textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final List<Widget> tiles = [];
    for (final azkar in favorites) {
      final isCompleted = azkar.isCompletedToday;
      final theme = IslamicTheme.of(context);
      tiles.add(
        HIGTile(
          label: settings.locale.languageCode == 'ar'
              ? azkar.textArabic
              : azkar.text,
          subtitleWidget: Text(
            settings.locale.languageCode == 'ar'
                ? azkar.translation
                : azkar.reference,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            isCompleted
                ? 'completed'.tr()
                : '${azkar.todayCount}/${azkar.count}',
            style: IslamicTextStyles.labelMedium.copyWith(
              color: theme.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () => _openAzkarCounter(azkar),
        ),
      );
    }

    return HIGGroup(
      header: 'favorites',
      children: tiles,
    );
  }

  void _showCategoryAzkar(
    AzkarCategory category,
    AzkarProvider provider,
    SettingsProvider settings,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryAzkarSheet(
        category: category,
        onOpenCounter: _openAzkarCounter,
      ),
    );
  }
}

/// Small pill showing the number of azkar in a category.
class _CategoryProgress extends StatelessWidget {
  final int count;
  const _CategoryProgress({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = IslamicTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: IslamicSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: theme.red.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(IslamicRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.chevron_right,
            size: 14,
            color: theme.textTertiary,
          ),
          const SizedBox(width: IslamicSpacing.xs),
          Text(
            '$count',
            style: IslamicTextStyles.labelSmall.copyWith(
              color: theme.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryAzkarSheet extends StatelessWidget {
  final AzkarCategory category;
  final Function(Azkar) onOpenCounter;

  const _CategoryAzkarSheet({
    required this.category,
    required this.onOpenCounter,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = IslamicTheme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(IslamicRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.separator,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(IslamicSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    settings.locale.languageCode == 'ar'
                        ? category.nameArabic
                        : category.name,
                    style: IslamicTextStyles.titleLarge.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: theme.textTertiary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Scrollable list of azkar, capped by the parent max-height.
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: IslamicSpacing.md),
              child: HIGGroup(
                children: [
                  for (final azkar in category.azkar)
                    _AzkarSheetTile(
                      azkar: azkar,
                      onTap: () => onOpenCounter(azkar),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AzkarSheetTile extends StatelessWidget {
  final Azkar azkar;
  final VoidCallback onTap;

  const _AzkarSheetTile({required this.azkar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = IslamicTheme.of(context);
    final isCompleted = azkar.isCompletedToday;

    return HIGTile(
      onTap: onTap,
      label: settings.locale.languageCode == 'ar'
          ? azkar.textArabic
          : azkar.text,
      subtitleWidget: Padding(
        padding: const EdgeInsets.only(right: 0),
        child: Row(
          children: [
            Text(
              '${azkar.count} ${'times'.tr()}',
              style: IslamicTextStyles.labelSmall.copyWith(
                color: isCompleted ? theme.accent : theme.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (azkar.reference.isNotEmpty) ...[
              const SizedBox(width: IslamicSpacing.sm),
              Expanded(
                child: Text(
                  settings.locale.languageCode == 'ar'
                      ? azkar.referenceArabic
                      : azkar.reference,
                  style: IslamicTextStyles.bodySmall.copyWith(
                    color: theme.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_right,
        size: 16,
        color: theme.textTertiary,
      ),
    );
  }
}

class _AzkarCounterSheet extends StatefulWidget {
  final Azkar azkar;
  final int initialCount;
  final Function(int) onComplete;

  const _AzkarCounterSheet({
    required this.azkar,
    required this.initialCount,
    required this.onComplete,
  });

  @override
  State<_AzkarCounterSheet> createState() => _AzkarCounterSheetState();
}

class _AzkarCounterSheetState extends State<_AzkarCounterSheet>
    with SingleTickerProviderStateMixin {
  late int _count;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _increment() {
    if (_count < widget.azkar.count) {
      setState(() => _count++);
      _animationController.forward(from: 0);
      if (_count >= widget.azkar.count) {
        widget.onComplete(_count);
      }
    }
  }

  void _decrement() {
    if (_count > 0) {
      setState(() => _count--);
    }
  }

  void _reset() {
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = IslamicTheme.of(context);
    final isCompleted = _count >= widget.azkar.count;
    final progress = _count / widget.azkar.count;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(IslamicRadius.xl),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(IslamicSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: IslamicSpacing.lg),
              decoration: BoxDecoration(
                color: theme.separator,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Progress ring with the target/current counter (e.g. 10/3).
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: theme.separator.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? theme.accent : theme.red,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_animationController.value * 0.2),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${widget.azkar.count}',
                                    style: IslamicTextStyles.displayLarge.copyWith(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w300,
                                      color: isCompleted
                                          ? theme.accent
                                          : theme.textPrimary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/$_count',
                                    style: IslamicTextStyles.displayLarge.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w400,
                                      color: theme.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: IslamicSpacing.xl),
            // Azkar text.
            Text(
              settings.locale.languageCode == 'ar'
                  ? widget.azkar.textArabic
                  : widget.azkar.text,
              style: IslamicTextStyles.arabicLarge.copyWith(
                fontSize: 24,
                color: theme.textPrimary,
              ),
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            if (widget.azkar.translation.isNotEmpty) ...[
              const SizedBox(height: IslamicSpacing.md),
              Text(
                settings.locale.languageCode == 'ar'
                    ? widget.azkar.translation
                    : widget.azkar.translation,
                style: IslamicTextStyles.bodyMedium.copyWith(
                  color: theme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: IslamicSpacing.xl),
            // Controls.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: _decrement,
                  icon: const Icon(CupertinoIcons.minus),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.separator.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: IslamicSpacing.lg),
                IconButton.filled(
                  onPressed: _increment,
                  icon: Icon(
                    CupertinoIcons.plus,
                    color: theme.textPrimary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.red,
                    padding: const EdgeInsets.all(IslamicSpacing.lg),
                  ),
                ),
                const SizedBox(width: IslamicSpacing.lg),
                IconButton.filled(
                  onPressed: _reset,
                  icon: Icon(
                    CupertinoIcons.arrow_counterclockwise,
                    color: theme.textPrimary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.separator.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
            if (isCompleted) ...[
              const SizedBox(height: IslamicSpacing.lg),
              Container(
                padding: const EdgeInsets.all(IslamicSpacing.md),
                decoration: BoxDecoration(
                  color: theme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(IslamicRadius.md),
                  border: Border.all(
                    color: theme.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_seal_fill,
                      color: theme.accent,
                    ),
                    const SizedBox(width: IslamicSpacing.sm),
                    Text(
                      'azkar_completed'.tr(),
                      style: IslamicTextStyles.titleMedium.copyWith(
                        color: theme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

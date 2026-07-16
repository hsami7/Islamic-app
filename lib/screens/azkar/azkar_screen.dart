import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../constants/app_design.dart';
import '../../models/azkar.dart';
import '../../providers/azkar_provider.dart';
import '../../providers/settings_provider.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;
  Azkar? _selectedAzkar;
  int _currentCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAzkarCounter(Azkar azkar) {
    setState(() {
      _selectedAzkar = azkar;
      _currentCount = 0;
    });
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
    final settings = context.watch<SettingsProvider>();
    final azkarProvider = context.watch<AzkarProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? IslamicColors.darkSystemGroupedBackground
          : IslamicColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(azkarProvider, settings),
          _buildTabBar(azkarProvider, isDark),
          _buildTabBarView(azkarProvider, settings),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(AzkarProvider provider, SettingsProvider settings) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('azkar'.tr(), style: IslamicTextStyles.titleLarge),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IslamicColors.azkarRed.withValues(alpha: 0.15),
                IslamicColors.primaryGreen.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.arrow_counterclockwise),
          onPressed: () => provider.resetDailyCompletions(),
        ),
      ],
    );
  }

  Widget _buildTabBar(AzkarProvider provider, bool isDark) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        tabBar: TabBar(
          controller: _tabController,
          labelStyle: IslamicTextStyles.labelMedium,
          unselectedLabelStyle: IslamicTextStyles.labelMedium,
          indicatorColor: IslamicColors.azkarRed,
          indicatorWeight: 3,
          labelColor: IslamicColors.azkarRed,
          unselectedLabelColor: isDark
              ? IslamicColors.darkLabelTertiary
              : IslamicColors.labelTertiary,
          dividerColor: Colors.transparent,
          isScrollable: true,
          tabs: [
            Tab(text: 'categories'.tr()),
            Tab(text: 'favorites'.tr()),
          ],
        ),
        backgroundColor: isDark
            ? IslamicColors.darkSystemBackground
            : IslamicColors.systemBackground,
      ),
    );
  }

  Widget _buildTabBarView(AzkarProvider provider, SettingsProvider settings) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoriesView(provider, settings),
          _buildFavoritesView(provider, settings),
        ],
      ),
    );
  }

  Widget _buildCategoriesView(AzkarProvider provider, SettingsProvider settings) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(IslamicSpacing.md),
      itemCount: provider.categories.length,
      itemBuilder: (context, index) {
        final category = provider.categories[index];
        return _buildCategoryCard(category, provider, settings);
      },
    );
  }

  Widget _buildCategoryCard(AzkarCategory category, AzkarProvider provider, SettingsProvider settings) {
    final azkarList = category.azkar;

    return Card(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.md),
      child: InkWell(
        onTap: () => _showCategoryAzkar(category, provider, settings),
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(IslamicSpacing.md),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [IslamicColors.azkarRed, IslamicColors.accentGold],
                  ),
                  borderRadius: BorderRadius.circular(IslamicRadius.md),
                ),
                child: const Icon(CupertinoIcons.sparkles, color: Colors.white, size: 28),
              ),
              const SizedBox(width: IslamicSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.locale.languageCode == 'ar'
                          ? category.nameArabic
                          : category.name,
                      style: IslamicTextStyles.titleMedium.copyWith(
                        color: settings.isDarkMode
                            ? IslamicColors.darkLabelPrimary
                            : IslamicColors.labelPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.locale.languageCode == 'ar'
                          ? category.descriptionArabic
                          : category.description,
                      style: IslamicTextStyles.bodySmall.copyWith(
                        color: settings.isDarkMode
                            ? IslamicColors.darkLabelSecondary
                            : IslamicColors.labelSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${azkarList.length} ${'azkar'.tr()}',
                      style: IslamicTextStyles.labelSmall.copyWith(
                        color: IslamicColors.azkarRed,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(CupertinoIcons.chevron_right, color: IslamicColors.labelTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesView(AzkarProvider provider, SettingsProvider settings) {
    final favorites = provider.favoriteAzkar;

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.heart, size: 48, color: IslamicColors.labelTertiary),
            const SizedBox(height: IslamicSpacing.md),
            Text('no_favorites'.tr(), style: IslamicTextStyles.bodyMedium),
            const SizedBox(height: IslamicSpacing.sm),
            Text(
              'add_favorites_hint'.tr(),
              style: IslamicTextStyles.bodySmall.copyWith(color: IslamicColors.labelTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(IslamicSpacing.md),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final azkar = favorites[index];
        return _buildAzkarCard(azkar, provider, settings);
      },
    );
  }

  void _showCategoryAzkar(AzkarCategory category, AzkarProvider provider, SettingsProvider settings) {
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

  Widget _buildAzkarCard(Azkar azkar, AzkarProvider provider, SettingsProvider settings) {
    final progress = azkar.progress;
    final isCompleted = azkar.isCompletedToday;

    return Card(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.md),
      child: InkWell(
        onTap: () => _openAzkarCounter(azkar),
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(IslamicSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      settings.locale.languageCode == 'ar' ? azkar.textArabic : azkar.text,
                      style: IslamicTextStyles.bodyMedium.copyWith(
                        fontFamily: settings.locale.languageCode == 'ar' ? 'Amiri' : 'SF Pro',
                        color: settings.isDarkMode ? IslamicColors.darkLabelPrimary : IslamicColors.labelPrimary,
                        height: 1.6,
                      ),
                      textDirection: settings.locale.languageCode == 'ar'
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      azkar.isFavorite
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: azkar.isFavorite ? IslamicColors.azkarRed : IslamicColors.labelTertiary,
                    ),
                    onPressed: () => provider.toggleFavorite(azkar.id),
                  ),
                ],
              ),
              const SizedBox(height: IslamicSpacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: IslamicSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? IslamicColors.primaryGreen.withValues(alpha: 0.15)
                          : IslamicColors.azkarRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(IslamicRadius.pill),
                    ),
                    child: Text(
                      isCompleted ? 'completed'.tr() : '${azkar.todayCount}/${azkar.count}',
                      style: IslamicTextStyles.labelSmall.copyWith(
                        color: isCompleted
                            ? IslamicColors.primaryGreen
                            : IslamicColors.azkarRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: IslamicSpacing.md),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(IslamicRadius.pill),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: IslamicColors.separator.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? IslamicColors.primaryGreen : IslamicColors.azkarRed,
                        ),
                      ),
                    ),
                  ),
                  if (azkar.reference.isNotEmpty) ...[
                    const SizedBox(width: IslamicSpacing.md),
                    Text(
                      azkar.reference,
                      style: IslamicTextStyles.bodySmall.copyWith(
                        color: IslamicColors.labelTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
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
    final isDark = settings.isDarkMode;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? IslamicColors.darkSystemBackground : IslamicColors.systemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(IslamicRadius.xl)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: IslamicColors.separator,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(IslamicSpacing.md),
            child: Row(
              children: [
                Text(
                  settings.locale.languageCode == 'ar' ? category.nameArabic : category.name,
                  style: IslamicTextStyles.titleLarge.copyWith(
                    color: isDark ? IslamicColors.darkLabelPrimary : IslamicColors.labelPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: IslamicSpacing.md),
              itemCount: category.azkar.length,
              itemBuilder: (context, index) {
                final azkar = category.azkar[index];
                return _AzkarListItem(azkar: azkar, onTap: () => onOpenCounter(azkar));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AzkarListItem extends StatelessWidget {
  final Azkar azkar;
  final VoidCallback onTap;

  const _AzkarListItem({required this.azkar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final progress = azkar.progress;
    final isCompleted = azkar.isCompletedToday;

    return Card(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IslamicRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(IslamicSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                settings.locale.languageCode == 'ar' ? azkar.textArabic : azkar.text,
                style: IslamicTextStyles.bodyMedium.copyWith(
                  fontFamily: settings.locale.languageCode == 'ar' ? 'Amiri' : 'SF Pro',
                  color: settings.isDarkMode ? IslamicColors.darkLabelPrimary : IslamicColors.labelPrimary,
                  height: 1.6,
                ),
                textDirection: settings.locale.languageCode == 'ar'
                    ? ui.TextDirection.rtl
                    : ui.TextDirection.ltr,
              ),
              const SizedBox(height: IslamicSpacing.sm),
              Row(
                children: [
                  Text(
                    '${azkar.count} ${'times'.tr()}',
                    style: IslamicTextStyles.labelSmall.copyWith(
                      color: isCompleted ? IslamicColors.primaryGreen : IslamicColors.azkarRed,
                    ),
                  ),
                  const Spacer(),
                  if (azkar.reference.isNotEmpty)
                    Text(azkar.reference, style: IslamicTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: IslamicSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(IslamicRadius.pill),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: IslamicColors.separator.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? IslamicColors.primaryGreen : IslamicColors.azkarRed,
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final isDark = settings.isDarkMode;
    final progress = _count / widget.azkar.count;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? IslamicColors.darkSystemBackground : IslamicColors.systemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(IslamicRadius.xl)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                color: IslamicColors.separator,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Progress ring
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: IslamicColors.separator.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _count >= widget.azkar.count
                          ? IslamicColors.primaryGreen
                          : IslamicColors.azkarRed,
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
                            child: Text(
                              '$_count',
                              style: IslamicTextStyles.displayLarge.copyWith(
                                fontSize: 72,
                                fontWeight: FontWeight.w300,
                                color: _count >= widget.azkar.count
                                    ? IslamicColors.primaryGreen
                                    : (isDark
                                        ? IslamicColors.darkLabelPrimary
                                        : IslamicColors.labelPrimary),
                              ),
                            ),
                          );
                        },
                      ),
                      Text(
                        '/${widget.azkar.count}',
                        style: IslamicTextStyles.headlineSmall.copyWith(
                          color: isDark
                              ? IslamicColors.darkLabelTertiary
                              : IslamicColors.labelTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: IslamicSpacing.xl),
            // Azkar text
            Text(
              settings.locale.languageCode == 'ar'
                  ? widget.azkar.textArabic
                  : widget.azkar.text,
              style: IslamicTextStyles.arabicLarge.copyWith(
                fontSize: 24,
                color: isDark
                    ? IslamicColors.darkLabelPrimary
                    : IslamicColors.labelPrimary,
              ),
              textDirection: ui.TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            if (widget.azkar.translation.isNotEmpty) ...[
              const SizedBox(height: IslamicSpacing.md),
              Text(
                widget.azkar.translation,
                style: IslamicTextStyles.bodyMedium.copyWith(
                  color: IslamicColors.labelSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: IslamicSpacing.xl),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: _decrement,
                  icon: const Icon(CupertinoIcons.minus),
                  style: IconButton.styleFrom(
                    backgroundColor: IslamicColors.separator.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: IslamicSpacing.lg),
                IconButton.filled(
                  onPressed: _increment,
                  icon: const Icon(CupertinoIcons.plus),
                  style: IconButton.styleFrom(
                    backgroundColor: IslamicColors.azkarRed,
                    padding: const EdgeInsets.all(IslamicSpacing.lg),
                  ),
                ),
                const SizedBox(width: IslamicSpacing.lg),
                IconButton.filled(
                  onPressed: _reset,
                  icon: const Icon(CupertinoIcons.arrow_counterclockwise),
                  style: IconButton.styleFrom(
                    backgroundColor: IslamicColors.separator.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
            if (_count >= widget.azkar.count) ...[
              const SizedBox(height: IslamicSpacing.lg),
              Container(
                padding: const EdgeInsets.all(IslamicSpacing.md),
                decoration: BoxDecoration(
                  color: IslamicColors.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(IslamicRadius.md),
                  border: Border.all(color: IslamicColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.checkmark_seal_fill, color: IslamicColors.primaryGreen),
                    const SizedBox(width: IslamicSpacing.sm),
                    Text(
                      'azkar_completed'.tr(),
                      style: IslamicTextStyles.titleMedium.copyWith(
                        color: IslamicColors.primaryGreenDark,
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

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _TabBarDelegate({required this.tabBar, required this.backgroundColor});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../constants/app_design.dart';
import '../../models/hadith.dart';
import '../../providers/hadith_provider.dart';
import '../../providers/settings_provider.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HadithProvider>().loadCollections();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final hadithProvider = context.watch<HadithProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? IslamicColors.darkSystemGroupedBackground
          : IslamicColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(hadithProvider, settings),
          _buildSearchBar(settings),
          _buildTabBar(hadithProvider, isDark),
          _buildTabBarView(hadithProvider, settings),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(HadithProvider provider, SettingsProvider settings) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('hadith'.tr(), style: IslamicTextStyles.titleLarge),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IslamicColors.hadithPurple.withValues(alpha: 0.15),
                IslamicColors.primaryGreen.withValues(alpha: 0.05),
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
        PopupMenuButton<String>(
          icon: const Icon(CupertinoIcons.book_fill),
          onSelected: (value) => provider.selectCollection(value),
          itemBuilder: (context) => provider.collections.map((c) {
            return PopupMenuItem(
              value: c.id,
              child: Text(c.nameArabic.isNotEmpty ? c.nameArabic : c.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar(SettingsProvider settings) {
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
                    hintText: 'search_hadith'.tr(),
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
                  onChanged: (value) async {
                    setState(() => _searchQuery = value);
                    if (value.length >= 2) {
                      final results = await context.read<HadithProvider>().searchHadiths(value);
                      // Navigate to search results
                    }
                  },
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildTabBar(HadithProvider provider, bool isDark) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        tabBar: TabBar(
          controller: _tabController,
          labelStyle: IslamicTextStyles.labelMedium,
          unselectedLabelStyle: IslamicTextStyles.labelMedium,
          indicatorColor: IslamicColors.hadithPurple,
          indicatorWeight: 3,
          labelColor: IslamicColors.hadithPurple,
          unselectedLabelColor: isDark
              ? IslamicColors.darkLabelTertiary
              : IslamicColors.labelTertiary,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: 'collections'.tr()),
            Tab(text: 'bookmarks'.tr()),
          ],
        ),
        backgroundColor: isDark
            ? IslamicColors.darkSystemBackground
            : IslamicColors.systemBackground,
      ),
    );
  }

  Widget _buildTabBarView(HadithProvider provider, SettingsProvider settings) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildCollectionsView(provider, settings),
          _buildBookmarksView(provider, settings),
        ],
      ),
    );
  }

  Widget _buildCollectionsView(HadithProvider provider, SettingsProvider settings) {
    if (provider.isLoadingCollections) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.collections.isEmpty) {
      return Center(child: Text('no_collections'.tr()));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(IslamicSpacing.md),
      itemCount: provider.collections.length,
      itemBuilder: (context, index) {
        final collection = provider.collections[index];
        return _buildCollectionCard(collection, provider, settings);
      },
    );
  }

  Widget _buildCollectionCard(HadithCollection collection, HadithProvider provider, SettingsProvider settings) {
    final isSelected = provider.selectedCollection == collection.id;

    return Card(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.md),
      child: InkWell(
        onTap: () {
          provider.selectCollection(collection.id);
          provider.loadHadiths(collection.id);
        },
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IslamicRadius.lg),
            border: isSelected
                ? Border.all(color: IslamicColors.hadithPurple, width: 2)
                : null,
          ),
          padding: const EdgeInsets.all(IslamicSpacing.md),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [IslamicColors.hadithPurple, IslamicColors.accentGold],
                  ),
                  borderRadius: BorderRadius.circular(IslamicRadius.md),
                ),
                child: Icon(CupertinoIcons.book, color: Colors.white, size: 28),
              ),
              const SizedBox(width: IslamicSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.locale.languageCode == 'ar' && collection.nameArabic.isNotEmpty
                          ? collection.nameArabic
                          : collection.name,
                      style: IslamicTextStyles.titleMedium.copyWith(
                        color: IslamicColors.labelPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      settings.locale.languageCode == 'ar' && collection.authorArabic.isNotEmpty
                          ? collection.authorArabic
                          : collection.author,
                      style: IslamicTextStyles.bodySmall.copyWith(
                        color: IslamicColors.labelTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${collection.totalHadiths} ${'hadiths'.tr()}',
                      style: IslamicTextStyles.labelSmall.copyWith(
                        color: IslamicColors.hadithPurple,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(CupertinoIcons.checkmark_circle_fill, color: IslamicColors.hadithPurple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksView(HadithProvider provider, SettingsProvider settings) {
    final bookmarks = provider.bookmarkedHadiths;

    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.bookmark, size: 48, color: IslamicColors.labelTertiary),
            const SizedBox(height: IslamicSpacing.md),
            Text('no_bookmarks'.tr(), style: IslamicTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(IslamicSpacing.md),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final hadith = bookmarks[index];
        return _buildHadithCard(hadith, provider, settings);
      },
    );
  }

  Widget _buildHadithCard(Hadith hadith, HadithProvider provider, SettingsProvider settings) {
    return Card(
      margin: const EdgeInsets.only(bottom: IslamicSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(IslamicSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: IslamicSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: IslamicColors.hadithPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(IslamicRadius.pill),
                  ),
                  child: Text(
                    '${hadith.collection.toUpperCase()} ${hadith.number}',
                    style: IslamicTextStyles.labelSmall.copyWith(
                      color: IslamicColors.hadithPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(CupertinoIcons.bookmark_fill, color: IslamicColors.accentGold),
                  onPressed: () => provider.toggleBookmark(hadith.id),
                ),
              ],
            ),
            const SizedBox(height: IslamicSpacing.sm),
            Text(
              settings.locale.languageCode == 'ar' && hadith.textArabic.isNotEmpty
                  ? hadith.textArabic
                  : hadith.text,
              style: IslamicTextStyles.bodyMedium.copyWith(
                fontFamily: settings.locale.languageCode == 'ar' ? 'Amiri' : 'SF Pro',
                height: 1.6,
              ),
              textDirection: settings.locale.languageCode == 'ar'
                  ? ui.TextDirection.rtl
                  : ui.TextDirection.ltr,
            ),
            const SizedBox(height: IslamicSpacing.sm),
            if (hadith.grade.isNotEmpty)
              Row(
                children: [
                  Icon(CupertinoIcons.star_fill, size: 14, color: IslamicColors.accentGold),
                  const SizedBox(width: 4),
                  Text(
                    'grade: ${hadith.grade}',
                    style: IslamicTextStyles.bodySmall.copyWith(
                      color: IslamicColors.accentGold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    hadith.narrator.isNotEmpty ? hadith.narrator : hadith.reference,
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
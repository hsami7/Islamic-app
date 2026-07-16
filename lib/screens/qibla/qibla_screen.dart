import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../constants/app_design.dart';
import '../../theme/islamic_theme.dart';
import '../../widgets/hig.dart';
import '../../providers/qibla_provider.dart';
import '../../providers/settings_provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _compassAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _compassAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<QiblaProvider>()
          .initialize(context.read<SettingsProvider>());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qiblaProvider = context.watch<QiblaProvider>();
    final theme = IslamicTheme.of(context);

    return Scaffold(
      backgroundColor: theme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(qiblaProvider, theme),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(IslamicSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCompass(qiblaProvider, theme),
                    const SizedBox(height: IslamicSpacing.xl),
                    _buildInstruction(qiblaProvider, theme),
                    const SizedBox(height: IslamicSpacing.lg),
                    _buildDistanceCard(qiblaProvider, theme),
                    const SizedBox(height: IslamicSpacing.lg),
                    _buildCalibrateButton(qiblaProvider, theme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(QiblaProvider provider, IslamicTheme theme) {
    return SliverAppBar(
      expandedHeight: 96,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: theme.background,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'qibla'.tr(),
          style: IslamicTextStyles.titleLarge.copyWith(color: theme.textPrimary),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IslamicColors.qiblaOrange.withValues(alpha: 0.12),
                IslamicColors.primaryGreen.withValues(alpha: 0.04),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(CupertinoIcons.refresh, color: theme.textPrimary),
          onPressed: () =>
              provider.loadQiblaDirection(context.read<SettingsProvider>()),
        ),
      ],
    );
  }

  Widget _buildCompass(QiblaProvider provider, IslamicTheme theme) {
    return AnimatedBuilder(
      animation: _compassAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.card,
                border: Border.all(
                  color: theme.separator.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: IslamicShadows.cardElevated,
              ),
            ),
            // Direction marks
            ...List.generate(36, (index) {
              final angle = index * 10.0;
              final isMajor = angle % 30 == 0;
              return Positioned.fill(
                child: CustomPaint(
                  painter: _CompassMarkPainter(
                    angle: angle,
                    isMajor: isMajor,
                    color: isMajor
                        ? IslamicColors.qiblaOrange
                        : theme.separator.withValues(alpha: 0.5),
                  ),
                ),
              );
            }),
            // Kaaba at center
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    IslamicColors.qiblaOrange,
                    IslamicColors.accentGold,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: IslamicColors.qiblaOrange.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.location_fill,
                color: Colors.white,
                size: 36,
              ),
            ),
            // Compass needle
            Transform.rotate(
              angle: provider.getArrowRotation(),
              child: Container(
                width: 4,
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      IslamicColors.qiblaOrange,
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // North label
            Positioned(
              top: 10,
              child: Text(
                'N',
                style: IslamicTextStyles.labelMedium.copyWith(
                  color: IslamicColors.azkarRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Qibla label
            Positioned(
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: IslamicSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: IslamicColors.qiblaOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(IslamicRadius.pill),
                ),
                child: Text(
                  'QIBLA ${provider.qiblaDirection?.formattedDirection ?? ''}',
                  style: IslamicTextStyles.labelSmall.copyWith(
                    color: IslamicColors.qiblaOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstruction(QiblaProvider provider, IslamicTheme theme) {
    final instruction = provider.getDirectionInstruction();
    final isFacing = instruction.contains('facing');
    final color =
        isFacing ? IslamicColors.primaryGreen : IslamicColors.qiblaOrange;

    return Container(
      padding: const EdgeInsets.all(IslamicSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isFacing
                ? CupertinoIcons.checkmark_seal_fill
                : CupertinoIcons.arrow_turn_up_right,
            size: 32,
            color: color,
          ),
          const SizedBox(height: IslamicSpacing.sm),
          Text(
            instruction,
            style: IslamicTextStyles.titleMedium.copyWith(
              color: isFacing
                  ? IslamicColors.primaryGreenDark
                  : IslamicColors.qiblaOrange,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceCard(QiblaProvider provider, IslamicTheme theme) {
    return HIGCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            'distance_to_kaaba'.tr(),
            provider.getDistanceToKaaba(),
            CupertinoIcons.location,
            IslamicColors.qiblaOrange,
            theme,
          ),
          _buildDivider(),
          _buildInfoItem(
            'qibla_direction'.tr(),
            provider.qiblaDirection?.formattedDirection ?? '--°',
            CupertinoIcons.compass,
            IslamicColors.prayerBlue,
            theme,
          ),
          _buildDivider(),
          _buildInfoItem(
            'coordinates'.tr(),
            provider.qiblaDirection != null
                ? '${provider.qiblaDirection!.latitude.toStringAsFixed(4)}°, ${provider.qiblaDirection!.longitude.toStringAsFixed(4)}°'
                : '--',
            CupertinoIcons.map_pin,
            IslamicColors.qiblaOrange,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
    IslamicTheme theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: IslamicSpacing.xs),
        Text(value, style: IslamicTextStyles.titleMedium.copyWith(color: color)),
        Text(
          label,
          style: IslamicTextStyles.bodySmall.copyWith(color: theme.textTertiary),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: IslamicTheme.of(context).separator,
    );
  }

  Widget _buildCalibrateButton(QiblaProvider provider, IslamicTheme theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () =>
            provider.calibrateCompass(context.read<SettingsProvider>()),
        icon: const Icon(CupertinoIcons.arrow_clockwise),
        label: Text('calibrate'.tr()),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: IslamicSpacing.md),
          foregroundColor:
              provider.isCalibrating ? IslamicColors.qiblaOrange : IslamicColors.primaryGreen,
          side: BorderSide(
            color: provider.isCalibrating
                ? IslamicColors.qiblaOrange
                : IslamicColors.primaryGreen,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _CompassMarkPainter extends CustomPainter {
  final double angle;
  final bool isMajor;
  final Color color;

  _CompassMarkPainter({
    required this.angle,
    required this.isMajor,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final radian = angle * (3.14159 / 180);

    final startOffset = Offset(
      center.dx + (radius - (isMajor ? 20 : 10)) * math.cos(-radian),
      center.dy + (radius - (isMajor ? 20 : 10)) * math.sin(-radian),
    );
    final endOffset = Offset(
      center.dx + (radius - 2) * math.cos(-radian),
      center.dy + (radius - 2) * math.sin(-radian),
    );

    final paint = Paint()
      ..color = color
      ..strokeWidth = isMajor ? 3 : 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(startOffset, endOffset, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

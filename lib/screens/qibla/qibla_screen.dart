import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../constants/app_design.dart';
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
      context.read<QiblaProvider>().initialize(context.read<SettingsProvider>());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final qiblaProvider = context.watch<QiblaProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? IslamicColors.darkSystemGroupedBackground
          : IslamicColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(qiblaProvider, settings),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(IslamicSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCompass(qiblaProvider, settings),
                    const SizedBox(height: IslamicSpacing.xl),
                    _buildInstruction(qiblaProvider, settings),
                    const SizedBox(height: IslamicSpacing.lg),
                    _buildDistanceCard(qiblaProvider, settings),
                    const SizedBox(height: IslamicSpacing.lg),
                    _buildCalibrateButton(qiblaProvider, settings),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(QiblaProvider provider, SettingsProvider settings) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('qibla'.tr(), style: IslamicTextStyles.titleLarge),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IslamicColors.qiblaOrange.withValues(alpha: 0.15),
                IslamicColors.primaryGreen.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.refresh),
          onPressed: () => provider.loadQiblaDirection(context.read<SettingsProvider>()),
        ),
      ],
    );
  }

  Widget _buildCompass(QiblaProvider provider, SettingsProvider settings) {
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
                border: Border.all(
                  color: IslamicColors.separator.withValues(alpha: 0.3),
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
                        : IslamicColors.separator.withValues(alpha: 0.5),
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

  Widget _buildInstruction(QiblaProvider provider, SettingsProvider settings) {
    final instruction = provider.getDirectionInstruction();

    return Container(
      padding: const EdgeInsets.all(IslamicSpacing.md),
      decoration: BoxDecoration(
        color: instruction.contains('facing')
            ? IslamicColors.primaryGreen.withValues(alpha: 0.15)
            : IslamicColors.qiblaOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(IslamicRadius.lg),
        border: Border.all(
          color: instruction.contains('facing')
              ? IslamicColors.primaryGreen.withValues(alpha: 0.3)
              : IslamicColors.qiblaOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            instruction.contains('facing')
                ? CupertinoIcons.checkmark_seal_fill
                : CupertinoIcons.arrow_turn_up_right,
            size: 32,
            color: instruction.contains('facing')
                ? IslamicColors.primaryGreen
                : IslamicColors.qiblaOrange,
          ),
          const SizedBox(height: IslamicSpacing.sm),
          Text(
            instruction,
            style: IslamicTextStyles.titleMedium.copyWith(
              color: instruction.contains('facing')
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

  Widget _buildDistanceCard(QiblaProvider provider, SettingsProvider settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(IslamicSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              'distance_to_kaaba'.tr(),
              provider.getDistanceToKaaba(),
              CupertinoIcons.location,
              IslamicColors.qiblaOrange,
            ),
            _buildDivider(),
            _buildInfoItem(
              'qibla_direction'.tr(),
              provider.qiblaDirection?.formattedDirection ?? '--°',
              CupertinoIcons.compass,
              IslamicColors.prayerBlue,
            ),
            _buildDivider(),
            _buildInfoItem(
              'coordinates'.tr(),
              provider.qiblaDirection != null
                  ? '${provider.qiblaDirection!.latitude.toStringAsFixed(4)}°, ${provider.qiblaDirection!.longitude.toStringAsFixed(4)}°'
                  : '--',
              CupertinoIcons.map_pin,
              IslamicColors.hadithPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: IslamicSpacing.xs),
        Text(value, style: IslamicTextStyles.titleMedium.copyWith(color: color)),
        Text(label, style: IslamicTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: IslamicColors.separator,
    );
  }

  Widget _buildCalibrateButton(QiblaProvider provider, SettingsProvider settings) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => provider.calibrateCompass(context.read<SettingsProvider>()),
        icon: const Icon(CupertinoIcons.arrow_clockwise),
        label: Text('calibrate'.tr()),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: IslamicSpacing.md),
          side: BorderSide(
            color: provider.isCalibrating ? IslamicColors.qiblaOrange : IslamicColors.primaryGreen,
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
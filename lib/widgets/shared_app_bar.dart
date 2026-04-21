import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'notification_widgets.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;

  const SharedAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(106);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // Frosted glass base
        color:
            isDark
                ? AppTheme.darkBackground.withValues(alpha: 0.75)
                : AppTheme.neuBg.withValues(alpha: 0.72),
        border: Border(
          bottom: BorderSide(
            color:
                isDark
                    ? AppTheme.neuAccent.withValues(alpha: 0.12)
                    : AppTheme.neuAccent.withValues(alpha: 0.14),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : AppTheme.neuShadowDark.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  height: 76,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Left: Drawer / Back button ──────────────────────
                      Builder(
                        builder: (context) {
                          final canPop = Navigator.canPop(context);
                          return _BarButton(
                            icon:
                                canPop
                                    ? Icons.arrow_back_rounded
                                    : Icons.menu_rounded,
                            onTap: () {
                              if (canPop) {
                                Navigator.pop(context);
                              } else if (onMenuPressed != null) {
                                onMenuPressed!();
                              } else {
                                Scaffold.of(context).openDrawer();
                              }
                            },
                            label: canPop ? 'Back' : 'Menu',
                          );
                        },
                      ),

                      // ── Center: Brand + screen label ─────────────────────
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Gradient shimmer brand name
                            _BrandName(),

                            const SizedBox(height: 4),

                            // Date pill + screen label row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _DatePill(),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    title.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: context.secondaryText.withValues(
                                        alpha: 0.85,
                                      ),
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Right: Theme toggle + Notification / custom actions ─
                      if (actions != null)
                        Row(mainAxisSize: MainAxisSize.min, children: actions!)
                      else
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Dark / Light mode toggle
                            _ThemeToggleButton(),
                            SizedBox(width: 8),
                            // Notification bell
                            _NotifButton(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // ── Animated accent gradient line at the bottom ────────────
              _AccentLine(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Brand name with gradient shimmer ─────────────────────────────────────────
class _BrandName extends StatefulWidget {
  @override
  State<_BrandName> createState() => _BrandNameState();
}

class _BrandNameState extends State<_BrandName>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, __) {
        final t = _shimmerCtrl.value;
        return ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                begin: Alignment(-1.5 + 3 * t, 0),
                end: Alignment(0.5 + 3 * t, 0),
                colors: const [
                  AppTheme.neuAccent,
                  AppTheme.neuAccentLight,
                  Color(0xFFFFB3D1), // shimmer highlight
                  AppTheme.neuAccentLight,
                  AppTheme.neuAccent,
                ],
                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'HerFlowmate',
            textAlign: TextAlign.center,
            style: AppTheme.brandStyle(fontSize: 22),
          ),
        );
      },
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }
}

// ── Theme Toggle Button ───────────────────────────────────────────────────────
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final storage = context.read<StorageService>();

    return _BarButton(
      icon: isDark ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
      onTap: () async {
        await storage.toggleDarkMode();
      },
      label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      iconColor:
          isDark
              ? const Color(0xFFFFD166) // warm amber for sun
              : const Color(0xFF9B6FFF), // purple for moon
    );
  }
}

// ── Notification Button ───────────────────────────────────────────────────────
class _NotifButton extends StatelessWidget {
  const _NotifButton();

  @override
  Widget build(BuildContext context) {
    return _BarButton(
      icon: Icons.notifications_none_rounded,
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const NotificationPanel(),
        );
      },
      label: 'Notifications',
      badge: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DatePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final dateStr = '${now.day} ${months[now.month - 1]}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neuAccent.withValues(alpha: 0.12),
            AppTheme.neuAccentLight.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.neuAccent.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        dateStr,
        style: AppTheme.poppins(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: context.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Animated gradient accent line ─────────────────────────────────────────────
class _AccentLine extends StatefulWidget {
  @override
  State<_AccentLine> createState() => _AccentLineState();
}

class _AccentLineState extends State<_AccentLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        return Container(
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: [
                Colors.transparent,
                isDark
                    ? AppTheme.neuAccentLight.withValues(alpha: 0.45)
                    : AppTheme.neuAccent.withValues(alpha: 0.35),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Left / Right button ────────────────────────────────────────────────────────
class _BarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final Color? iconColor;
  final bool badge;

  const _BarButton({
    required this.icon,
    required this.onTap,
    required this.label,
    this.iconColor,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedIconColor =
        iconColor ??
        (isDark
            ? AppTheme.darkOnSurface.withValues(alpha: 0.85)
            : AppTheme.neuTextPrimary.withValues(alpha: 0.8));

    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppTheme.neuAccent.withValues(alpha: 0.15),
          highlightColor: AppTheme.neuAccent.withValues(alpha: 0.08),
          child: Ink(
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : AppTheme.neuAccent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : AppTheme.neuAccent.withValues(alpha: 0.12),
                width: 0.8,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: resolvedIconColor, size: 20),
                  if (badge)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.neuAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

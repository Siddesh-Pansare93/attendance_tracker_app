import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated gradient background with floating orbs for premium look
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _orbController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultColors = isDark
        ? [
            const Color(0xFF0D0D1A),
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ]
        : [
            const Color(0xFFF8F9FF),
            const Color(0xFFEEF2FF),
            const Color(0xFFE8EFFF),
          ];

    final gradientColors = widget.colors ?? defaultColors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Animated gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                  stops: [0.0, 0.5 + (_controller.value * 0.2), 1.0],
                ),
              ),
            ),
            // Floating orbs
            ..._buildFloatingOrbs(isDark),
            // Content
            widget.child,
          ],
        );
      },
    );
  }

  List<Widget> _buildFloatingOrbs(bool isDark) {
    final orbColors = isDark
        ? [
            const Color(0xFF6366F1).withValues(alpha: 0.15),
            const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            const Color(0xFF22C55E).withValues(alpha: 0.08),
          ]
        : [
            const Color(0xFF6366F1).withValues(alpha: 0.1),
            const Color(0xFF8B5CF6).withValues(alpha: 0.08),
            const Color(0xFF22C55E).withValues(alpha: 0.06),
          ];

    return [
      _buildOrb(
        animation: _orbController,
        color: orbColors[0],
        size: 200,
        top: 80,
        right: -50,
        delay: 0,
      ),
      _buildOrb(
        animation: _orbController,
        color: orbColors[1],
        size: 150,
        bottom: 200,
        left: -40,
        delay: 0.3,
      ),
      _buildOrb(
        animation: _orbController,
        color: orbColors[2],
        size: 100,
        bottom: 100,
        right: 50,
        delay: 0.6,
      ),
    ];
  }

  Widget _buildOrb({
    required Animation<double> animation,
    required Color color,
    required double size,
    double? top,
    double? bottom,
    double? left,
    double? right,
    double delay = 0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = (animation.value + delay) % 1.0;
        final yOffset = math.sin(t * 2 * math.pi) * 20;
        final xOffset = math.cos(t * 2 * math.pi) * 15;

        return Positioned(
          top: top != null ? top + yOffset : null,
          bottom: bottom != null ? bottom - yOffset : null,
          left: left != null ? left + xOffset : null,
          right: right != null ? right - xOffset : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, color.withValues(alpha: 0)],
              ),
            ),
          ),
        );
      },
    );
  }
}

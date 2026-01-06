import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:smart_attendance_app/core/theme/app_theme.dart';

/// Circular attendance indicator with percentage, animated ring, and status color
class AttendanceIndicator extends StatefulWidget {
  final double percentage;
  final double threshold;
  final double size;
  final bool showLabel;
  final bool animate;

  const AttendanceIndicator({
    super.key,
    required this.percentage,
    required this.threshold,
    this.size = 80,
    this.showLabel = true,
    this.animate = true,
  });

  @override
  State<AttendanceIndicator> createState() => _AttendanceIndicatorState();
}

class _AttendanceIndicatorState extends State<AttendanceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AttendanceIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation =
          Tween<double>(
            begin: _animation.value,
            end: widget.percentage,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentPercentage = widget.animate
            ? _animation.value
            : widget.percentage;
        final color = AppTheme.getStatusColor(
          currentPercentage,
          widget.threshold,
        );

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                      blurRadius: widget.size * 0.3,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              // Custom painted ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  percentage: currentPercentage,
                  color: color,
                  strokeWidth: widget.size * 0.1,
                  isDark: isDark,
                ),
              ),
              // Percentage text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${currentPercentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: widget.size * 0.2,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (widget.showLabel)
                    Text(
                      AppTheme.getStatusText(
                        currentPercentage,
                        widget.threshold,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color.withValues(alpha: 0.8),
                        fontSize: widget.size * 0.11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom ring painter for gradient effect
class _RingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double strokeWidth;
  final bool isDark;

  _RingPainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.15 : 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (percentage / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle.clamp(0, 2 * math.pi),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}

/// Linear attendance indicator bar with gradient
class AttendanceBar extends StatelessWidget {
  final double percentage;
  final double threshold;
  final double height;
  final bool showGradient;

  const AttendanceBar({
    super.key,
    required this.percentage,
    required this.threshold,
    this.height = 8,
    this.showGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStatusColor(percentage, threshold);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (percentage / 100).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: showGradient
                ? LinearGradient(colors: [color, color.withValues(alpha: 0.7)])
                : null,
            color: showGradient ? null : color,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

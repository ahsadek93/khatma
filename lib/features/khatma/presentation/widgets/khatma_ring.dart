import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:khatmah/core/theme/app_colors.dart';

/// The app's signature element: a khatma drawn as a ring of [total] segments
/// (one per juz'), filling emerald → gold as ajzāʾ are completed. Echoes a
/// misbaḥa (prayer beads) and the circular sense of *khatma* — a completed seal.
///
/// Pass [child] to place content (a count, an icon) at the centre.
class KhatmaRing extends StatelessWidget {
  const KhatmaRing({
    super.key,
    required this.completed,
    required this.total,
    this.strokeWidth = 12,
    this.child,
  });

  final int completed;
  final int total;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _KhatmaRingPainter(
        completed: completed,
        total: total,
        strokeWidth: strokeWidth,
        startColor: scheme.primary,
        endColor: AppColors.gold,
        trackColor: scheme.outlineVariant,
        isComplete: total > 0 && completed >= total,
      ),
      child: child == null
          ? const SizedBox.expand()
          : Padding(
              padding: EdgeInsets.all(strokeWidth + 6),
              child: Center(child: child),
            ),
    );
  }
}

class _KhatmaRingPainter extends CustomPainter {
  _KhatmaRingPainter({
    required this.completed,
    required this.total,
    required this.strokeWidth,
    required this.startColor,
    required this.endColor,
    required this.trackColor,
    required this.isComplete,
  });

  final int completed;
  final int total;
  final double strokeWidth;
  final Color startColor;
  final Color endColor;
  final Color trackColor;
  final bool isComplete;

  @override
  void paint(Canvas canvas, Size size) {
    final segments = total <= 0 ? 1 : total;
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    if (radius <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final segmentAngle = (2 * math.pi) / segments;
    final gap = segments > 1 ? segmentAngle * 0.30 : 0.0;
    final sweep = segmentAngle - gap;
    const start = -math.pi / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor.withValues(alpha: 0.45);

    final clamped = completed < 0
        ? 0
        : (completed > segments ? segments : completed);

    for (var i = 0; i < segments; i++) {
      final from = start + i * segmentAngle + gap / 2;
      if (i >= clamped) {
        canvas.drawArc(rect, from, sweep, false, track);
        continue;
      }
      // Emerald → gold sweep as the ring fills: the illumination metaphor.
      final t = segments == 1 ? 1.0 : i / (segments - 1);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(startColor, endColor, t)!;
      canvas.drawArc(rect, from, sweep, false, paint);
    }

    if (isComplete) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..color = endColor.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, radius, glow);
    }
  }

  @override
  bool shouldRepaint(_KhatmaRingPainter old) =>
      old.completed != completed ||
      old.total != total ||
      old.strokeWidth != strokeWidth ||
      old.startColor != startColor ||
      old.endColor != endColor ||
      old.trackColor != trackColor ||
      old.isComplete != isComplete;
}

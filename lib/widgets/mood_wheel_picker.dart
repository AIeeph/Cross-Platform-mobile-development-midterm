import 'dart:math' as math;

import 'package:flutter/material.dart';

class MoodWheelPicker extends StatefulWidget {
  const MoodWheelPicker({
    super.key,
    required this.moods,
    required this.selectedMood,
    required this.onChanged,
  });

  final List<String> moods;
  final String? selectedMood;
  final ValueChanged<String?> onChanged;

  @override
  State<MoodWheelPicker> createState() => _MoodWheelPickerState();
}

class _MoodWheelPickerState extends State<MoodWheelPicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  Animation<double>? _rotationAnimation;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )
      ..addListener(() {
        if (_rotationAnimation != null) {
          setState(() {
            _rotation = _rotationAnimation!.value;
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant MoodWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMood != widget.selectedMood) {
      final index = widget.selectedMood == null ? null : widget.moods.indexOf(widget.selectedMood!);
      if (index != null && index >= 0) {
        _animateToIndex(index);
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _animateToIndex(int index) {
    final step = 2 * math.pi / widget.moods.length;
    final target = -index * step;
    _rotationAnimation = Tween<double>(begin: _rotation, end: target).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOutBack),
    );
    _rotationController.forward(from: 0);
  }

  void _pickMood(Offset localPosition, double size) {
    final center = Offset(size / 2, size / 2);
    final vector = localPosition - center;
    final radius = vector.distance;
    if (radius < size * 0.20) {
      widget.onChanged(null);
      return;
    }

    var angle = math.atan2(vector.dy, vector.dx);
    angle -= _rotation;
    if (angle < -math.pi / 2) {
      angle += 2 * math.pi;
    }
    angle += math.pi / 2;

    final normalized = (angle % (2 * math.pi)) / (2 * math.pi);
    final index = (normalized * widget.moods.length).floor().clamp(0, widget.moods.length - 1);
    final mood = widget.moods[index];

    if (widget.selectedMood == mood) {
      widget.onChanged(null);
    } else {
      _animateToIndex(index);
      widget.onChanged(mood);
    }
  }

  @override
  Widget build(BuildContext context) {
    const size = 210.0;
    final selectedLabel = widget.selectedMood ?? 'All moods';

    return Column(
      children: [
        GestureDetector(
          onTapUp: (details) => _pickMood(details.localPosition, size),
          onPanUpdate: (details) => _pickMood(details.localPosition, size),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: _rotation,
                  child: CustomPaint(
                    size: const Size.square(size),
                    painter: _MoodWheelPainter(
                      count: widget.moods.length,
                      labels: widget.moods,
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                  ),
                ),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        selectedLabel,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap or drag on wheel to pick mood',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MoodWheelPainter extends CustomPainter {
  _MoodWheelPainter({
    required this.count,
    required this.labels,
    required this.colorScheme,
  });

  final int count;
  final List<String> labels;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = size.width * 0.24;
    final sweep = (2 * math.pi) / count;

    final baseColors = [
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
    ];

    for (var i = 0; i < count; i++) {
      final start = -math.pi / 2 + i * sweep;
      final paint = Paint()
        ..color = baseColors[i % baseColors.length].withValues(alpha: 0.88)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx + innerRadius * math.cos(start), center.dy + innerRadius * math.sin(start))
        ..arcTo(Rect.fromCircle(center: center, radius: radius), start, sweep, false)
        ..lineTo(center.dx + innerRadius * math.cos(start + sweep), center.dy + innerRadius * math.sin(start + sweep))
        ..arcTo(Rect.fromCircle(center: center, radius: innerRadius), start + sweep, -sweep, false)
        ..close();

      canvas.drawPath(path, paint);

      final textAngle = start + sweep / 2;
      final textOffset = Offset(
        center.dx + (radius * 0.72) * math.cos(textAngle),
        center.dy + (radius * 0.72) * math.sin(textAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 80);

      textPainter.paint(
        canvas,
        Offset(textOffset.dx - textPainter.width / 2, textOffset.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MoodWheelPainter oldDelegate) {
    return oldDelegate.count != count || oldDelegate.labels != labels || oldDelegate.colorScheme != colorScheme;
  }
}

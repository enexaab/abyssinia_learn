import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SoftProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color color;
  final Color trackColor;

  const SoftProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color = AppColors.primary,
    this.trackColor = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        color: color,
        backgroundColor: trackColor,
      ),
    );
  }
}

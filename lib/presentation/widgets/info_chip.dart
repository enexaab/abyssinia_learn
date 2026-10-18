import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool onDark;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? Colors.white : AppColors.primaryDark;
    final bg = onDark ? Colors.white.withOpacity(0.2) : AppColors.primaryLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

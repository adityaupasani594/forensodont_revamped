import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class QualityIndicator extends StatelessWidget {
  final String label;
  final int score; // 1 to 5

  const QualityIndicator({
    super.key,
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'IBM Plex Mono'),
          ),
          const SizedBox(height: 2),
          Row(
            children: List.generate(5, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < score ? _getColor() : AppColors.surface,
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (score >= 4) return AppColors.success;
    if (score >= 2) return AppColors.warning;
    return AppColors.error;
  }
}

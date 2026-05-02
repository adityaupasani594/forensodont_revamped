import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ConfidenceBreakdownCard extends StatelessWidget {
  final Map<String, double> scores;

  const ConfidenceBreakdownCard({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: scores.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'IBM Plex Mono'),
                  ),
                  Text(
                    '${(entry.value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: _getColor(entry.value),
                      fontFamily: 'IBM Plex Mono',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: entry.value,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(_getColor(entry.value)),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColor(double score) {
    if (score >= 0.85) return AppColors.success;
    if (score >= 0.65) return AppColors.warning;
    return AppColors.error;
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MatchProgressTimeline extends StatelessWidget {
  final List<MatchStage> stages;

  const MatchProgressTimeline({super.key, required this.stages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stage = stages[index];
        final isLast = index == stages.length - 1;
        
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  _buildIcon(stage),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: stage.isCompleted ? AppColors.success : AppColors.surface,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.label,
                      style: TextStyle(
                        color: stage.isActive ? AppColors.primary : (stage.isCompleted ? AppColors.textPrimary : AppColors.textSecondary),
                        fontWeight: stage.isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (stage.isActive)
                      Text(
                        stage.subtitle ?? 'Processing...',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIcon(MatchStage stage) {
    if (stage.isCompleted) {
      return const Icon(Icons.check_circle, color: AppColors.success, size: 24);
    }
    if (stage.isActive) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
    );
  }
}

class MatchStage {
  final String label;
  final String? subtitle;
  final bool isActive;
  final bool isCompleted;

  MatchStage({
    required this.label,
    this.subtitle,
    this.isActive = false,
    this.isCompleted = false,
  });
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CaseStatusChip extends StatelessWidget {
  final String status;

  const CaseStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'drafting':
        color = AppColors.textSecondary;
        icon = Icons.edit_note;
        break;
      case 'processing':
        color = AppColors.primary;
        icon = Icons.sync;
        break;
      case 'awaiting review':
        color = AppColors.warning;
        icon = Icons.rate_review;
        break;
      case 'confirmed':
        color = AppColors.success;
        icon = Icons.verified;
        break;
      case 'no match':
        color = AppColors.error;
        icon = Icons.block;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(BorderSide(color: color.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBM Plex Mono',
            ),
          ),
        ],
      ),
    );
  }
}

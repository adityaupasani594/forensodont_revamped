import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FDIToothChart extends StatefulWidget {
  final Set<int> missingTeeth;
  final Function(int) onToothTap;
  final bool readOnly;

  const FDIToothChart({
    super.key,
    required this.missingTeeth,
    required this.onToothTap,
    this.readOnly = false,
  });

  @override
  State<FDIToothChart> createState() => _FDIToothChartState();
}

class _FDIToothChartState extends State<FDIToothChart> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            const Text("Upper Arch", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            _buildArch([18, 17, 16, 15, 14, 13, 12, 11], [21, 22, 23, 24, 25, 26, 27, 28]),
            const SizedBox(height: 24),
            _buildArch([48, 47, 46, 45, 44, 43, 42, 41], [31, 32, 33, 34, 35, 36, 37, 38]),
            const SizedBox(height: 8),
            const Text("Lower Arch", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildArch(List<int> right, List<int> left) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...right.map((id) => _buildTooth(id)),
        const SizedBox(width: 12),
        ...left.map((id) => _buildTooth(id)),
      ],
    );
  }

  Widget _buildTooth(int id) {
    final isMissing = widget.missingTeeth.contains(id);
    return GestureDetector(
      onTap: widget.readOnly ? null : () => widget.onToothTap(id),
      child: Container(
        width: 34,
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isMissing ? AppColors.surface : AppColors.card,
          border: Border.all(
            color: isMissing ? AppColors.error.withOpacity(0.5) : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              id.toString(),
              style: TextStyle(
                fontSize: 10,
                color: isMissing ? AppColors.textSecondary : AppColors.textPrimary,
                fontFamily: 'IBM Plex Mono',
              ),
            ),
            if (isMissing)
              const Icon(Icons.close, size: 24, color: AppColors.error),
          ],
        ),
      ),
    );
  }
}

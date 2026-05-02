import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ExpertAnnotationScreen extends StatefulWidget {
  final String caseId;
  final String candidateId;

  const ExpertAnnotationScreen({
    super.key,
    required this.caseId,
    required this.candidateId,
  });

  @override
  State<ExpertAnnotationScreen> createState() => _ExpertAnnotationScreenState();
}

class _ExpertAnnotationScreenState extends State<ExpertAnnotationScreen> {
  Color _selectedColor = AppColors.primary;
  double _strokeWidth = 3.0;
  String _activeTool = 'pen'; // pen, arrow, rect, text, eraser

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Expert Annotation'),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  Center(child: Image.network('https://via.placeholder.com/1200x600', fit: BoxFit.contain)),
                  // This would be the interactive drawing layer
                  Positioned.fill(
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        // Drawing logic here
                      },
                      child: CustomPaint(
                        painter: DrawingPainter(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolIcon('pen', Icons.edit),
              _buildToolIcon('arrow', Icons.north_east),
              _buildToolIcon('rect', Icons.crop_square),
              _buildToolIcon('text', Icons.text_fields),
              _buildToolIcon('eraser', Icons.auto_fix_normal),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Color:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              _buildColorDot(AppColors.primary),
              _buildColorDot(AppColors.success),
              _buildColorDot(AppColors.warning),
              _buildColorDot(AppColors.error),
              _buildColorDot(Colors.white),
              const Spacer(),
              const Text('Size:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              SizedBox(
                width: 100,
                child: Slider(
                  value: _strokeWidth,
                  min: 1,
                  max: 10,
                  onChanged: (v) => setState(() => _strokeWidth = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(String tool, IconData icon) {
    final isActive = _activeTool == tool;
    return IconButton(
      icon: Icon(icon, color: isActive ? AppColors.primary : AppColors.textSecondary),
      onPressed: () => setState(() => _activeTool = tool),
      style: IconButton.styleFrom(
        backgroundColor: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)] : null,
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Logic to paint stored strokes/shapes
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

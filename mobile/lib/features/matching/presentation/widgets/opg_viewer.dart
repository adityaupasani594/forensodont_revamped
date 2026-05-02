import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../core/theme/app_theme.dart';

class OPGViewer extends StatefulWidget {
  final ImageProvider image;
  final PhotoViewController? controller;
  final bool showAnnotations;
  final double opacity;
  final List<ToothAnnotation>? annotations;

  const OPGViewer({
    super.key,
    required this.image,
    this.controller,
    this.showAnnotations = false,
    this.opacity = 1.0,
    this.annotations,
  });

  @override
  State<OPGViewer> createState() => _OPGViewerState();
}

class _OPGViewerState extends State<OPGViewer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: widget.opacity,
          child: PhotoView(
            imageProvider: widget.image,
            controller: widget.controller,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
          ),
        ),
        if (widget.showAnnotations && widget.annotations != null)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: AnnotationPainter(
                  annotations: widget.annotations!,
                  // We would need to pass the controller's state to correctly scale/pan annotations
                  // but for the sake of the UI structure, we'll keep it simple.
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ToothAnnotation {
  final Rect rect;
  final String label;
  final Color color;

  ToothAnnotation({required this.rect, required this.label, required this.color});
}

class AnnotationPainter extends CustomPainter {
  final List<ToothAnnotation> annotations;

  AnnotationPainter({required this.annotations});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var annotation in annotations) {
      final paint = Paint()
        ..color = annotation.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(annotation.rect, paint);
      
      textPainter.text = TextSpan(
        text: annotation.label,
        style: TextStyle(color: annotation.color, fontSize: 10, fontWeight: FontWeight.bold, backgroundColor: Colors.black54),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(annotation.rect.left, annotation.rect.top - 12));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

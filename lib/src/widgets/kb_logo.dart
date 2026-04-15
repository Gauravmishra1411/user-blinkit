import 'dart:math';
import 'package:flutter/material.dart';

class KBLogo extends StatefulWidget {
  final double size;
  const KBLogo({Key? key, this.size = 180}) : super(key: key);

  @override
  State<KBLogo> createState() => _KBLogoState();
}

class _KBLogoState extends State<KBLogo> with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _reverseRotateController;

  @override
  void initState() {
    super.initState();
    
    // Outer ring rotation (20 seconds)
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Inner ring reverse rotation (15 seconds)
    _reverseRotateController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _rotateController.repeat();
        _reverseRotateController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _reverseRotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FittedBox(
        child: SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateController.value * 2 * pi,
                    child: CustomPaint(
                      size: const Size(180, 180),
                      painter: RingPainter(
                        radius: 85,
                        strokeWidth: 1.5,
                        color: const Color(0xffff3c5f),
                        dashPattern: [8, 6],
                      ),
                    ),
                  );
                },
              ),
              
              // Inner ring (reverse)
              AnimatedBuilder(
                animation: _reverseRotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_reverseRotateController.value * 2 * pi,
                    child: CustomPaint(
                      size: const Size(180, 180),
                      painter: RingPainter(
                        radius: 70,
                        strokeWidth: 1,
                        color: const Color(0xff5f8aff),
                        dashPattern: [4, 8],
                      ),
                    ),
                  );
                },
              ),
              
              // Center diamond mark
              CustomPaint(
                size: const Size(180, 180),
                painter: DiamondPainter(),
              ),
              
              // KB Text overlay
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scaleX: -1,
                    child: const Text(
                      'K',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        fontFamily: 'Syne',
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-12, 0),
                    child: const Text(
                      'B',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Syne',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for dashed rings
class RingPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Color color;
  final List<double> dashPattern;

  RingPainter({
    required this.radius,
    required this.strokeWidth,
    required this.color,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw dashed circle
    _drawDashedCircle(canvas, center, radius, paint);
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const steps = 360;
    double dashLength = dashPattern[0];
    double gapLength = dashPattern[1];
    double totalPattern = dashLength + gapLength;

    for (int i = 0; i < steps; i++) {
      double startAngle = (i / steps) * 2 * pi;
      double endAngle = ((i + 1) / steps) * 2 * pi;

      // Determine if this segment should be drawn
      double patternPosition = (i / steps * 2 * pi) % totalPattern;
      if (patternPosition < dashLength / totalPattern * 2 * pi) {
        final startPoint = Offset(
          center.dx + radius * cos(startAngle),
          center.dy + radius * sin(startAngle),
        );
        final endPoint = Offset(
          center.dx + radius * cos(endAngle),
          center.dy + radius * sin(endAngle),
        );
        canvas.drawLine(startPoint, endPoint, paint);
      }
    }
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) => false;
}

// Custom painter for diamond shape
class DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Top triangle
    final topTriangle = Path()
      ..moveTo(center.dx, center.dy - 50)
      ..lineTo(center.dx + 40, center.dy + 10)
      ..lineTo(center.dx, center.dy - 5)
      ..close();

    canvas.drawPath(topTriangle, Paint()..color = const Color(0xffff3c5f));

    // Bottom triangle
    final bottomTriangle = Path()
      ..moveTo(center.dx, center.dy - 5)
      ..lineTo(center.dx + 40, center.dy + 10)
      ..lineTo(center.dx, center.dy + 65)
      ..lineTo(center.dx - 40, center.dy + 10)
      ..close();

    canvas.drawPath(bottomTriangle, Paint()..color = const Color(0xff5f8aff));
  }

  @override
  bool shouldRepaint(DiamondPainter oldDelegate) => false;
}

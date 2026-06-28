import 'package:flutter/material.dart';

class FuturisticScannerOverlay extends StatelessWidget {
  final Animation<double> scanLineAnimation;
  final bool isRecordingAudio;

  const FuturisticScannerOverlay({
    super.key,
    required this.scanLineAnimation,
    this.isRecordingAudio = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bords futuristes (CustomPaint)
        Positioned.fill(
          child: CustomPaint(
            painter: _ScannerPainter(
              color: const Color(0xFF90CDC6), // _secondary (Turquoise)
            ),
          ),
        ),
        // Ligne de scan animée
        if (!isRecordingAudio)
          AnimatedBuilder(
            animation: scanLineAnimation,
            builder: (context, child) {
              final alignY = -0.8 + (scanLineAnimation.value * 1.6);
              return Align(
                alignment: Alignment(0, alignY),
                child: Container(
                  width: double.infinity,
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF90CDC6),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF90CDC6).withOpacity(0.8),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        // Si c'est l'audio, afficher une onde animée au centre
        if (isRecordingAudio)
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (index) {
                return AnimatedBuilder(
                  animation: scanLineAnimation,
                  builder: (context, child) {
                    final height = 20.0 +
                        (scanLineAnimation.value * 100.0 * ((index % 4) + 1)) % 80.0;
                    return Container(
                      width: 8,
                      height: height,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6C69D), // _tertiary (Pêche)
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF6C69D).withOpacity(0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _ScannerPainter extends CustomPainter {
  final Color color;
  _ScannerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 50.0;
    final double margin = 30.0;
    final double safeTop = 100.0;
    final double safeBottom = 150.0;

    // Coins supérieurs gauches
    canvas.drawLine(Offset(margin, safeTop + cornerLength), Offset(margin, safeTop), paint);
    canvas.drawLine(Offset(margin, safeTop), Offset(margin + cornerLength, safeTop), paint);

    // Coins supérieurs droits
    canvas.drawLine(Offset(size.width - margin - cornerLength, safeTop), Offset(size.width - margin, safeTop), paint);
    canvas.drawLine(Offset(size.width - margin, safeTop), Offset(size.width - margin, safeTop + cornerLength), paint);

    // Coins inférieurs gauches
    canvas.drawLine(Offset(margin, size.height - safeBottom - cornerLength), Offset(margin, size.height - safeBottom), paint);
    canvas.drawLine(Offset(margin, size.height - safeBottom), Offset(margin + cornerLength, size.height - safeBottom), paint);

    // Coins inférieurs droits
    canvas.drawLine(Offset(size.width - margin - cornerLength, size.height - safeBottom), Offset(size.width - margin, size.height - safeBottom), paint);
    canvas.drawLine(Offset(size.width - margin, size.height - safeBottom), Offset(size.width - margin, size.height - safeBottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'hanoi_screen.dart';
import 'slider-1.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    scale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );

    fade = Tween(begin: 0.0, end: 1.0).animate(controller);

    controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Slider1()),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),

      body: Stack(
        children: [
          const DotBackground(),

          Center(
            child: FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // ⚫ ICON CARD (dark theme)
                    Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.extension_rounded,
                        size: 70,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "TOWER OF HANOI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Recursion Puzzle Game",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 35),

                    const CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class DotBackground extends StatefulWidget {
  const DotBackground({super.key});

  @override
  State<DotBackground> createState() => _DotBackgroundState();
}

class _DotBackgroundState extends State<DotBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }
  @override
  void dispose() {
    controller.stop();   // optional but safe
    controller.dispose(); // ✅ IMPORTANT FIX
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          painter: DotPainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class DotPainter extends CustomPainter {
  final double value;

  DotPainter(this.value);

  // Deterministic pseudo-random values so every dot keeps a stable
  // size / speed / sway across frames instead of jumping around.
  double _rand(int seed) {
    final x = (seed * 12.9898) % 1000;
    return (x * 43758.5453) % 1.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const dotCount = 90;

    for (int i = 0; i < dotCount; i++) {

      final speedFactor = 0.4 + _rand(i * 7) * 1.0; // varying fall speed
      final radius = 1.0 + _rand(i * 13) * 2.2; // varying size (depth)
      final baseOpacity = 0.05 + _rand(i * 19) * 0.12; // farther dots are fainter

      // Twinkle: opacity gently breathes in and out on its own cycle
      // per dot, so the whole field doesn't flicker in unison.
      final twinkle =
          0.6 + 0.4 * math.sin((value * 2 * math.pi * 3) + (i * 12.9));
      final opacity = (baseOpacity * twinkle).clamp(0.0, 0.3);

      final baseX = _rand(i * 31) * size.width;

      // Gentle side-to-side sway as the dot falls, like drifting snow.
      final sway = math.sin((value * 2 * math.pi * speedFactor) + i) * 10;

      final x = (baseX + sway) % size.width;
      final y = ((value * speedFactor * size.height * 1.3) +
              (i * 71.0)) %
          (size.height + 40) -
          20;

      // Every ~12th dot carries a warm accent tint instead of plain
      // white — a subtle nod to the app's red/gold theme.
      final bool isAccent = i % 12 == 0;
      final Color dotColor = isAccent
          ? const Color(0xFFE53935)
          : (i % 12 == 6 ? const Color(0xFFFFD700) : Colors.white);

      final paint = Paint()..color = dotColor.withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Accent dots get a soft glow halo for a little extra sparkle.
      if (isAccent) {
        final glowPaint = Paint()
          ..color = dotColor.withOpacity(opacity * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), radius * 2.2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
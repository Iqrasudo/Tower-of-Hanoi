import 'package:flutter/material.dart';
import 'hanoi_screen.dart';
import 'SplashScreen.dart';
import 'user_input.dart';
class StartGame extends StatefulWidget {
  const StartGame({super.key});

  @override
  State<StartGame> createState() => _StartGameState();
}

class _StartGameState extends State<StartGame>
    with TickerProviderStateMixin {

  // =========================
  // CONTROLLERS
  // =========================
  late AnimationController _typingController;
  late AnimationController _buttonController;

  late Animation<double> _typingAnim;
  late Animation<double> _buttonScale;
  late Animation<double> _glowAnim;

  final String title = "TOWER OF HANOI";

  // =========================
  // INIT
  // =========================
  @override
  void initState() {
    super.initState();

    // 🔤 TYPING ANIMATION
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _typingAnim = CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    );

    _typingController.forward();

    // 🔘 BUTTON ANIMATION (SLOW PULSE)
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..repeat(reverse: true);

    _buttonScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _glowAnim = Tween<double>(
      begin: 8,
      end: 22,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _typingController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // =========================
  // TYPE TEXT BUILDER
  // =========================
  String getTypedText() {
    int count = (title.length * _typingAnim.value).toInt();
    return title.substring(0, count);
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),

      body: Stack(
        children: [

          // 🌑 FULL SCREEN BACKGROUND (FIXED)
          const Positioned.fill(
            child: DotBackground(),
          ),

          // 🌟 FOREGROUND UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // TITLE
                AnimatedBuilder(
                  animation: _typingAnim,
                  builder: (context, child) {
                    return Text(
                      getTypedText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50),

                // BUTTON
                AnimatedBuilder(
                  animation: _buttonController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonScale.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.6),
                              blurRadius: _glowAnim.value,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserInputScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "START GAME",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
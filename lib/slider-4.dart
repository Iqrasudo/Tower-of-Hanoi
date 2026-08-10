import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'start-game.dart';
class Slider4 extends StatefulWidget {
  const Slider4({super.key});

  @override
  State<Slider4> createState() => _Slider4State();
}

class _Slider4State extends State<Slider4>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget benefitBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.2),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 17,
          height: 1.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      body: Stack(children: [ const Positioned.fill(
      child: DotBackground(),
    ),SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Simple rules, infinite challenge.",
                  style: TextStyle(
                    color: Colors.redAccent,
                    letterSpacing: 3,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "BENEFITS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 30),

                benefitBox(
                  "Improves logical thinking and problem-solving skills.",
                ),

                benefitBox(
                  "Helps programmers understand recursion deeply.",
                ),

                benefitBox(
                  "Builds algorithmic thinking and coding confidence.",
                ),

                benefitBox(
                  "Teaches how large problems are divided into smaller tasks.",
                ),

                benefitBox(
                  "Useful for learning data structures and algorithms.",
                ),

                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StartGame(),
                        ),
                      );
                    },
                    child: const Text(
                      "NEXT",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                // Center(
                //   child: Text(
                //     "RECURSION • LOGIC • ALGORITHMS",
                //     style: TextStyle(
                //       color: Colors.white.withOpacity(0.4),
                //       letterSpacing: 3,
                //     ),
                //   ),
                // ),

                const SizedBox(height: 30),
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


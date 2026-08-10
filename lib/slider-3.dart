import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'slider-4.dart';

class Slider3 extends StatefulWidget {
  const Slider3({super.key});

  @override
  State<Slider3> createState() => _Slider3State();
}

class _Slider3State extends State<Slider3>
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

  Widget stepBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
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
                  "Algorithmic thinking starts here",
                  style: TextStyle(
                    color: Colors.redAccent,
                    letterSpacing: 3,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "HOW IT WORKS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 30),

                stepBox(
                  "Step 1: Move smaller disks from Source rod to Auxiliary rod.",
                ),

                stepBox(
                  "Step 2: Move the biggest disk from Source rod to Destination rod.",
                ),

                stepBox(
                  "Step 3: Move all smaller disks from Auxiliary rod to Destination rod.",
                ),

                stepBox(
                  "This process repeats recursively until every disk reaches the destination rod.",
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
                          builder: (_) => const Slider4(),
                        ),
                      );
                    },
                    child: const Text(
                      "NEXT",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
      )
    );
  }
}

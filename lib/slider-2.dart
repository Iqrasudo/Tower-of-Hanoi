import 'package:flutter/material.dart';
import 'SplashScreen.dart';
import 'slider-3.dart';

class Slider2 extends StatefulWidget {
  const Slider2({super.key});

  @override
  State<Slider2> createState() => _Slider2State();
}

class _Slider2State extends State<Slider2>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      body: Stack(children: [
      const Positioned.fill(
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
                  "Where recursion becomes reality",
                  style: TextStyle(
                    color: Colors.redAccent,
                    letterSpacing: 3,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "RECURSION ALGORITHM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: const Text(
                    "Recursion is a programming technique where a function calls itself repeatedly until a base condition becomes true. Tower of Hanoi is one of the most famous examples used to understand recursion.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      height: 1.7,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: const Text(
                    "tower(n-1, source, auxiliary)\nmove disk\ntower(n-1, auxiliary, destination)",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      height: 1.8,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "In Tower of Hanoi, recursion divides a big problem into smaller repeated problems until only one disk remains.",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    height: 1.7,
                  ),
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
                          builder: (_) => const Slider3(),
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
    ]
    )
    );
  }
}

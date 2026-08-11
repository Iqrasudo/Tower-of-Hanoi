import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'hanoi_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:github_sign_in_plus/github_sign_in_plus.dart';
import 'SplashScreen.dart';
import 'services/sound_service.dart';
import 'services/theme_service.dart';
class UserInputScreen extends StatefulWidget {
  const UserInputScreen({super.key});

  @override
  State<UserInputScreen> createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    SoundService.instance.init();
    SoundService.instance.playChime();
    SoundService.instance.startAmbient();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  final TextEditingController nameController =
  TextEditingController();

  String capitalizeWords(String text) {

    return text
        .trim()
        .split(" ")
        .map((word) {

      if (word.isEmpty) return "";

      return word[0].toUpperCase() +
          word.substring(1).toLowerCase();

    }).join(" ");
  }
  Future<User?> signInWithGitHub() async {

    try {

      const clientId = "Ov23lisDd757rs34sBYL";

      const clientSecret = "985f66ac91bada984d9413b2083eb9b2f40b0cf8";

      const redirectUrl =
          "https://towerofhanoi-705de.firebaseapp.com/__/auth/handler";

      final GitHubSignIn gitHubSignIn = GitHubSignIn(

        clientId: clientId,

        clientSecret: clientSecret,

        redirectUrl: redirectUrl,
      );

      final result = await gitHubSignIn.signIn(context);

      if (result.token == null) {
        return null;
      }

      final credential =
      GithubAuthProvider.credential(result.token!);

      UserCredential userCredential =
      await FirebaseAuth.instance
          .signInWithCredential(credential);

      return userCredential.user;

    } catch (e) {

      debugPrint(e.toString());

      return null;
    }
  }
  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<AppTheme>(
      valueListenable: ThemeService.instance.current,
      builder: (context, theme, _) {
        return Scaffold(

          backgroundColor: theme.background,

          body: Stack(children: [
          const Positioned.fill(
          child: DotBackground(),
        ),
        Center(

        child: Padding(

          padding: const EdgeInsets.all(25),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "WELCOME",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 50),

              // ⚠️ GITHUB REQUIREMENT NOTICE — gently pulsing to draw the eye
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Opacity(
                    opacity: _pulseAnim.value,
                    child: child,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.info_outline,
                          color: Colors.redAccent, size: 16),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "You must have a GitHub account to play this game",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ElevatedButton.icon(
                onPressed: () async {
                  SoundService.instance.playClick();
                  User? user = await signInWithGitHub();

                  if (user != null) {

                    final docRef = FirebaseFirestore.instance
                        .collection("players")
                        .doc(user.uid);

                    final doc = await docRef.get();

                    if (!doc.exists) {
                      await docRef.set({
                        "playerName": user.displayName ?? "PLAYER",
                        "completed": {
                          "3": false,
                          "4": false,
                          "5": false,
                          "6": false,
                          "7": false,
                          "8": false,
                        },
                        "email": user.email ?? "",
                        "photo": user.photoURL ?? "",
                        "createdAt": FieldValue.serverTimestamp(),
                      });
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HanoiScreen(
                          playerName: user.displayName ?? "PLAYER",
                        ),
                      ),
                    );
                  }
                },

                icon: const Icon(
                  Icons.code,
                  color: Colors.white,
                ),

                label: const Text(
                  "CONTINUE WITH GITHUB",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.headerBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: theme.accent.withOpacity(0.5)),
                ),
              ),
            ],
          ),

        ),
      ),
    ]
    ),
    );
      },
    );
  }
}
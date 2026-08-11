
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'leaderboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'SplashScreen.dart';
import 'user_input.dart';
import 'certificate_screen.dart';
import 'theme_picker_screen.dart';
import 'services/sound_service.dart';
import 'services/certificate_service.dart';
import 'services/theme_service.dart';
class HanoiScreen extends StatefulWidget {
  final String playerName;
  const HanoiScreen({super.key, required  this.playerName});

  @override
  State<HanoiScreen> createState() => _HanoiScreenState();
}

class _HanoiScreenState extends State<HanoiScreen> {
  Map<int, bool> completedLevels = {

    3: false,
    4: false,
    5: false,
    6: false,
    7: false,
    8: false,
  };
  Map<int, bool> bestCompletedLevels = {
    3: false,
    4: false,
    5: false,
    6: false,
    7: false,
    8: false,
  };
  Timer? timer;
  bool isPaused = false;
  int seconds = 0;
  int diskCount = 5;

  List<int> rodA = [];
  List<int> rodB = [];
  List<int> rodC = [];

  String? selectedRod;

  int moves = 0;

  bool gameStarted = false;

  bool soundMuted = false;
  AppTheme _theme = midnightMaroon;

  @override
  void initState() {
    super.initState();
    SoundService.instance.init();
    SoundService.instance.playChime();
    SoundService.instance.startAmbient();
    loadProgress();
    startGame();
  }

  // ==========================
  // GET ROD
  // ==========================

  List<int> getRod(String rod) {
    if (rod == "A") return rodA;
    if (rod == "B") return rodB;
    return rodC;
  }

  // ==========================
  // START GAME
  // ==========================
  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (!gameStarted || isPaused) {
        return;
      }

      setState(() {
        seconds++;
      });
    });
  }
  Future<void> saveProgress() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    print(bestCompletedLevels);

    await FirebaseFirestore.instance
        .collection("players")
        .doc(uid)
        .set({

      "playerName": widget.playerName,

      "completed": {

        "3": completedLevels[3] ?? false,
        "4": completedLevels[4] ?? false,
        "5": completedLevels[5] ?? false,
        "6": completedLevels[6] ?? false,
        "7": completedLevels[7] ?? false,
        "8": completedLevels[8] ?? false,

        "3_best": bestCompletedLevels[3] ?? false,
        "4_best": bestCompletedLevels[4] ?? false,
        "5_best": bestCompletedLevels[5] ?? false,
        "6_best": bestCompletedLevels[6] ?? false,
        "7_best": bestCompletedLevels[7] ?? false,
        "8_best": bestCompletedLevels[8] ?? false,
      }

    }, SetOptions(merge: true));

    print("DATA SAVED");
  }
  Future<void> loadProgress() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("players")
        .doc(uid)
        .get();

    if (doc.exists) {

      final data = doc.data();

      final completed = data?["completed"] ?? {};

      setState(() {

        completedLevels[3] = completed["3"] ?? false;
        completedLevels[4] = completed["4"] ?? false;
        completedLevels[5] = completed["5"] ?? false;
        completedLevels[6] = completed["6"] ?? false;
        completedLevels[7] = completed["7"] ?? false;
        completedLevels[8] = completed["8"] ?? false;

        bestCompletedLevels[3] =
            completed["3_best"] ?? false;

        bestCompletedLevels[4] =
            completed["4_best"] ?? false;

        bestCompletedLevels[5] =
            completed["5_best"] ?? false;

        bestCompletedLevels[6] =
            completed["6_best"] ?? false;

        bestCompletedLevels[7] =
            completed["7_best"] ?? false;

        bestCompletedLevels[8] =
            completed["8_best"] ?? false;
      });
    }
  }
  // Future<void> saveProgress() async {
  //
  //   await FirebaseFirestore.instance
  //       .collection("players")
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .set({
  //
  //     "playerName": widget.playerName,
  //
  //     "completed": {
  //
  //       "3": completedLevels[3],
  //       "4": completedLevels[4],
  //       "5": completedLevels[5],
  //       "6": completedLevels[6],
  //       "7": completedLevels[7],
  //       "8": completedLevels[8],
  //
  //       "3_best": bestCompletedLevels[3],
  //       "4_best": bestCompletedLevels[4],
  //       "5_best": bestCompletedLevels[5],
  //       "6_best": bestCompletedLevels[6],
  //       "7_best": bestCompletedLevels[7],
  //       "8_best": bestCompletedLevels[8],
  //     }
  //
  //   }, SetOptions(merge: true));
  // }
  // Future<void> saveProgress() async {

  //   await FirebaseFirestore.instance
  //       .collection("players")
  //       .doc(widget.playerName)
  //       .set({
  //
  //     "playerName": widget.playerName,
  //
  //     "completed": {
  //
  //       "3": completedLevels[3],
  //       "4": completedLevels[4],
  //       "5": completedLevels[5],
  //       "6": completedLevels[6],
  //       "7": completedLevels[7],
  //       "8": completedLevels[8],
  //     }
  //   });
  // }
  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });

    if (isPaused) {
      timer?.cancel();
      timer = null;
    } else {
      startTimer();
    }
  }

  void stopTimer() {

    timer?.cancel();
    timer=null;
  }

  void startGame() {
    timer?.cancel(); // ⭐ ADD THIS FIRST

    seconds = 0;
    moves = 0;
    isPaused = false;
    gameStarted = true;

    rodA = List.generate(diskCount, (i) => diskCount - i);
    rodB = [];
    rodC = [];

    selectedRod = null;

    startTimer(); // only once
  }
  // void startGame() {
  //   seconds=0;
  //   moves = 0;
  //
  //   startTimer();
  //
  //   selectedRod = null;
  //   rodA = List.generate(
  //     diskCount,
  //         (index) => diskCount - index,
  //   );
  //
  //   setState(() {
  //
  //     rodB = [];
  //     rodC = [];
  //
  //     moves = 0;
  //
  //     selectedRod = null;
  //
  //     gameStarted = true;
  //   });
  // }

  // ==========================
  // RESET
  // ==========================

  void resetGame() {
    timer?.cancel();

    seconds = 0;
    moves = 0;
    isPaused = false;
    gameStarted = true;

    rodA = List.generate(diskCount, (i) => diskCount - i);
    rodB = [];
    rodC = [];

    selectedRod = null;

    startTimer();
  }

  // ==========================
  // DISK SELECTOR DIALOG
  // ==========================

  void showDiskSelector() {

    int selectedDisks = diskCount;

    showDialog(
      context: context,

      builder: (_) {

        return AlertDialog(

          backgroundColor: const Color(0xFF1A1A1A),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Row(
            children: [

              Icon(
                Icons.layers,
                color: Colors.redAccent,
              ),

              SizedBox(width: 10),

              Text(
                "Choose Disks",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),

          content: StatefulBuilder(

            builder: (context, setDialogState) {

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    "$selectedDisks Disks",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Slider(

                    value: selectedDisks.toDouble(),

                    min: 3,
                    max: 8,

                    divisions: 5,

                    activeColor: Colors.redAccent,

                    inactiveColor: Colors.white24,

                    label: selectedDisks.toString(),

                    onChanged: (value) {

                      setDialogState(() {

                        selectedDisks = value.toInt();
                      });
                    },
                  ),
                ],
              );
            },
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),

            ElevatedButton.icon(

              onPressed: () {

                diskCount = selectedDisks;

                Navigator.pop(context);

                startGame();
              },

              icon: const Icon(Icons.play_arrow),

              label: const Text("Start Game"),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white
              ),
            ),
          ],
        );
      },
    );
  }
  bool canPlay() {
    return gameStarted && !isPaused;
  }
  // ==========================
  // SELECT ROD
  // ==========================

  void selectRod(String rod) {
    if (!gameStarted) return;
    if (isPaused) return;
    if (!canPlay()) return;
    setState(() {

      if (selectedRod == null) {

        if (getRod(rod).isNotEmpty) {

          selectedRod = rod;
        } else {
          SoundService.instance.playInvalid();
        }

      } else {

        moveDisk(selectedRod!, rod);

        selectedRod = null;
      }
    });
  }

  // ==========================
  // MOVE DISK
  // ==========================

  void moveDisk(String from, String to) {
    if (isPaused) return; // ⭐ ADD THIS
    if (!canPlay()) return;
    List<int> f = getRod(from);

    List<int> t = getRod(to);

    if (f.isEmpty) return;

    int disk = f.last;

    if (t.isNotEmpty && t.last < disk) {
      SoundService.instance.playInvalid();
      return;
    }

    setState(() {

      f.removeLast();

      t.add(disk);

      moves++;
    });

    SoundService.instance.playMove();

    checkWin();
  }

  // ==========================
  // APPLY MOVE FOR API
  // ==========================

  void applyMove(String from, String to) {
    // if (isPaused) return; // ⭐ ADD THIS
    // if (!canPlay()) return;
    List<int> f = getRod(from);

    List<int> t = getRod(to);

    if (f.isEmpty) return;

    int disk = f.last;

    if (t.isNotEmpty && t.last < disk) return;

    f.removeLast();

    t.add(disk);

    moves++;
  }

  // ==========================
  // AUTO SOLVE
  // ==========================

  Future<void> autoSolve() async {

    final url = Uri.parse(
      "https://iqrakhawar-tower-of-hanoi-backend.hf.space/hanoi/$diskCount",
    );

    try {

      timer?.cancel();
      timer=null;// stop old timer
      seconds = 0;
      moves = 0;
      isPaused = false;
      gameStarted = true;

      rodA = List.generate(diskCount, (i) => diskCount - i);
      rodB = [];
      rodC = [];

      selectedRod = null;

      startTimer();

      final response = await http.get(url);

      final List movesList = jsonDecode(response.body);

      for (var move in movesList) {

        while (isPaused) {
          await Future.delayed(const Duration(milliseconds: 200));

          // optional: exit if game reset
          if (!gameStarted) return;
        }

        await Future.delayed(const Duration(milliseconds: 400));

        if (!mounted) return;

        setState(() {
          applyMove(move["from"], move["to"]);
        });
      }
stopTimer();
      // checkWin();

    } catch (e) {

      print("AUTO SOLVE ERROR: $e");
    }
  }

  // ==========================
  // WIN CHECK
  // ==========================

  // void checkWin() {
  //
  //   if (rodC.length == diskCount) {
  //     stopTimer();
  //     showDialog(
  //
  //       context: context,
  //
  //       builder: (_) {
  //
  //         return AlertDialog(
  //
  //           backgroundColor: const Color(0xFF1A1A1A),
  //
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //
  //           title: const Row(
  //             children: [
  //
  //               Icon(
  //                 Icons.emoji_events,
  //                 color: Colors.amber,
  //               ),
  //
  //               SizedBox(width: 10),
  //
  //               Text(
  //                 "You Win!",
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //             ],
  //           ),
  //
  //           content: Text(
  //             "Completed in $moves moves & $seconds seconds",
  //
  //             style: const TextStyle(
  //               color: Colors.white70,
  //             ),
  //           ),
  //
  //
  //           actions: [
  //
  //             TextButton.icon(
  //
  //               onPressed: () {
  //
  //                 Navigator.pop(context);
  //
  //                 resetGame();
  //               },
  //
  //               icon: const Icon(
  //                 Icons.replay,
  //                 color: Colors.white,
  //               ),
  //
  //               label: const Text(
  //                 "Play Again", style: TextStyle(color: Colors.white),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }
  void checkWin() async {

    if (rodC.length == diskCount) {

      stopTimer();
      SoundService.instance.playWin();

      completedLevels[diskCount] = true;

      int minimumMoves = (1 << diskCount) - 1;

      bool isBest = moves <= minimumMoves;

      if (isBest) {
        bestCompletedLevels[diskCount] = true;
      }

      // SAVE COMPLETED LEVEL
      setState(() {


      });

      // SAVE TO FIREBASE
      await saveProgress();

      // ==========================
      // UPDATE THE PLAYER'S MASTERY CERTIFICATE RECORD
      // (one certificate per player, covering every level — not
      // one certificate per disk count)
      // ==========================
      try {
        await CertificateService.recordLevelCompletion(
          diskCount: diskCount,
          moves: moves,
          seconds: seconds,
          isBest: isBest,
          playerName: widget.playerName,
        );
      } catch (e) {
        print("CERTIFICATE SAVE ERROR: $e");
      }

      // Certificate only unlocks once every level (3-8) is both completed
      // AND completed in the minimum number of moves.
      final bool justFullyMastered = gameLevels.every((d) =>
              (completedLevels[d] ?? false)) &&
          gameLevels.every((d) => (bestCompletedLevels[d] ?? false));

      if (!mounted) return;

      showDialog(

        context: context,

        builder: (_) {

          return AlertDialog(

            backgroundColor: const Color(0xFF1A1A1A),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: const Row(

              children: [

                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                ),

                SizedBox(width: 10),

                Text(

                  "You Win!",

                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            content: Column(

              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  "Player : ${widget.playerName}",

                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(

                  "Completed $diskCount disks",

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text(

                  "Moves : $moves",

                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 5),

                Text(

                  "Time : ${formatDuration(seconds)}",

                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                if (isBest) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Text(
                      "🏆 BEST MOVES ACHIEVED",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],

                if (justFullyMastered) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.greenAccent),
                    ),
                    child: const Text(
                      "🎉 ALL LEVELS MASTERED!\nYour certificate is now unlocked.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            actions: [

              // CERTIFICATE (always visible — locked/unlocked handled inside the screen)
              TextButton.icon(
                onPressed: () {
                  SoundService.instance.playClick();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CertificateScreen(),
                    ),
                  );
                },
                icon: Icon(
                  justFullyMastered
                      ? Icons.workspace_premium
                      : Icons.card_membership,
                  color: justFullyMastered
                      ? Colors.amber
                      : Colors.lightBlueAccent,
                ),
                label: Text(
                  "My Certificate",
                  style: TextStyle(
                    color: justFullyMastered
                        ? Colors.amber
                        : Colors.lightBlueAccent,
                  ),
                ),
              ),

              // PLAY AGAIN
              TextButton.icon(

                onPressed: () {

                  SoundService.instance.playClick();
                  Navigator.pop(context);

                  resetGame();
                },

                icon: const Icon(
                  Icons.replay,
                  color: Colors.white,
                ),

                label: const Text(

                  "Play Again",

                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

              // LEADERBOARD
              TextButton.icon(

                onPressed: () {

                  SoundService.instance.playClick();
                  Navigator.pop(context);

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                      const LeaderboardScreen(),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.leaderboard,
                  color: Colors.amber,
                ),

                label: const Text(

                  "Leaderboard",

                  style: TextStyle(
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }
  // ==========================
  // STAT CHIP UI
  // ==========================

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _theme.accent, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================
  // DISK UI
  // ==========================

  // A distinct gradient per disk size so the tower reads clearly at a glance.
  static const List<List<Color>> _diskGradients = [
    [Color(0xFFFF6B6B), Color(0xFFE53935)], // 1 - red
    [Color(0xFFFFA726), Color(0xFFEF6C00)], // 2 - orange
    [Color(0xFFFFD54F), Color(0xFFF9A825)], // 3 - yellow
    [Color(0xFF66BB6A), Color(0xFF2E7D32)], // 4 - green
    [Color(0xFF4DD0E1), Color(0xFF00838F)], // 5 - cyan
    [Color(0xFF64B5F6), Color(0xFF1565C0)], // 6 - blue
    [Color(0xFFBA68C8), Color(0xFF6A1B9A)], // 7 - purple
    [Color(0xFFF06292), Color(0xFFAD1457)], // 8 - pink
  ];

  Widget disk(int size) {

    final colors = _diskGradients[(size - 1) % _diskGradients.length];

    return Container(

      height: 34,

      width: 42 + (size * 16),

      margin: const EdgeInsets.symmetric(vertical: 2.5),

      decoration: BoxDecoration(

        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),

        borderRadius: BorderRadius.circular(8),

        border: Border.all(
          color: Colors.white24,
        ),

        boxShadow: [
          BoxShadow(
            color: colors[1].withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Center(

        child: Text(

          size.toString(),

          style: const TextStyle(

            color: Colors.white,

            fontWeight: FontWeight.bold,

            fontSize: 15,

            shadows: [
              Shadow(color: Colors.black45, blurRadius: 3),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================
  // ROD UI
  // ==========================

  // Widget rod(String name, List<int> data) {
  //
  //   bool selected = selectedRod == name;
  //   bool isDestination = name == "C";
  //   return GestureDetector(
  //
  //     onTap: () => selectRod(name),
  //
  //     child: SizedBox(
  //
  //       width: 95,
  //
  //       height: 498,
  //
  //       child: Stack(
  //
  //         alignment: Alignment.bottomCenter,
  //
  //         children: [
  //
  //           Positioned(
  //
  //             bottom: 55,
  //
  //             child: Container(
  //
  //               height: 370,
  //
  //               width: 9,
  //
  //               decoration: BoxDecoration(
  //
  //                 color: selected
  //                     ? Colors.redAccent
  //                     : isDestination
  //                     ? Colors.greenAccent
  //                     : Colors.grey.shade700,
  //
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //             ),
  //           ),
  //
  //           Positioned(
  //
  //             bottom: 55,
  //
  //             child: Column(
  //
  //               mainAxisSize: MainAxisSize.min,
  //
  //               children: [
  //
  //                 for (int i = data.length - 1; i >= 0; i--)
  //
  //                   disk(data[i]),
  //               ],
  //             ),
  //           ),
  //
  //           Positioned(
  //
  //             bottom: 35,
  //
  //             child: Container(
  //
  //               height: 10,
  //
  //               width: 100,
  //
  //               decoration: BoxDecoration(
  //
  //                 color: Colors.grey.shade800,
  //
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //             ),
  //
  //           ),
  //
  //           Positioned(
  //             top: 4,
  //             bottom: 2,
  //             child: Column(
  //               children: [
  //                 Text(
  //                   name,
  //                   style: TextStyle(
  //                     color: selected
  //                         ? Colors.redAccent
  //                         : Colors.white70,
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //
  //                 if (isDestination)
  //                   const Text(
  //                     "DESTINATION",
  //                     style: TextStyle(
  //                       color: Colors.greenAccent,
  //                       fontSize: 10,
  //                       letterSpacing: 1,
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget rod(String name, List<int> data) {
    bool selected = selectedRod == name;
    bool isDestination = name == "C";

    String getLabel() {
      if (name == "A") return "SOURCE";
      if (name == "B") return "AUXILIARY";
      return "DESTINATION";
    }

    final Color accent = selected
        ? _theme.accent
        : isDestination
            ? const Color(0xFF66BB6A)
            : Colors.white54;

    return GestureDetector(
      onTap: () => selectRod(name),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // 🏷 LABEL PILL — always in normal flow, so it can never be
          // clipped off-screen no matter how tall the rod area is.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.redAccent.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.6)),
            ),
            child: Column(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: accent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  getLabel(),
                  style: TextStyle(
                    color: accent.withOpacity(0.85),
                    fontSize: 8,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 🪵 ROD + DISKS — flexible height, always fits the available space.
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accent.withOpacity(0.25),
                        accent.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: accent.withOpacity(0.6),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (int i = data.length - 1; i >= 0; i--)
                        disk(data[i]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🟫 BASE
          Container(
            height: 10,
            width: 100,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withOpacity(0.5)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ==========================
  // UI
  // ==========================
  @override
  void dispose() {

    timer?.cancel();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<AppTheme>(
      valueListenable: ThemeService.instance.current,
      builder: (context, theme, _) {
        _theme = theme;
        return Scaffold(

      backgroundColor: theme.background,

      body: Stack(

        children: [

          const DotBackground(),

          Column(

            children: [

              const SizedBox(height: 50),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  const Text(

    "TOWER OF HANOI",

    style: TextStyle(

      color: Colors.white,

      fontSize: 26,

      fontWeight: FontWeight.bold,

      letterSpacing: 3,
    ),
  ),
  IconButton(
    onPressed: () {
      SoundService.instance.playClick();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ThemePickerScreen(),
        ),
      );
    },
    icon: const Icon(
      Icons.palette_outlined,
      color: Colors.white70,
    ),
  ),
  IconButton(
    onPressed: () {
      setState(() {
        soundMuted = !soundMuted;
        SoundService.instance.toggleMute();
      });
    },
    icon: Icon(
      soundMuted ? Icons.volume_off : Icons.volume_up,
      color: Colors.white70,
    ),
  ),
  IconButton(
    onPressed: () {
      SoundService.instance.playClick();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CertificateScreen(),
        ),
      );
    },
    icon: const Icon(
      Icons.card_membership,
      color: Colors.white70,
    ),
  ),
  IconButton(
    onPressed: () async {

      await FirebaseAuth.instance.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        ),
            (route) => false,
      );
    },
    icon: const Icon(
      Icons.logout,
      color: Colors.white70,
    ),
  ),
],),


              const SizedBox(height: 10),
              Text(

                widget.playerName,

                style: TextStyle(
                  color: theme.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 12),
              TweenAnimationBuilder(

                tween: Tween<double>(begin: 0.9, end: 1.1),

                duration: const Duration(seconds: 2),

                curve: Curves.easeInOut,

                builder: (context, value, child) {

                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },

                onEnd: () {
                  setState(() {});
                },

                child: Container(

                  decoration: BoxDecoration(

                    shape: BoxShape.circle,

                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFA500),
                      ],
                    ),

                    boxShadow: [

                      BoxShadow(
                        color: Colors.amber.withOpacity(0.8),
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),

                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),

                  child: IconButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                          const LeaderboardScreen(),
                        ),
                      );
                    },

                    icon: const Icon(

                      Icons.leaderboard_rounded,

                      color: Colors.black,

                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statChip(Icons.swap_horiz, "$moves", "MOVES"),
                  const SizedBox(width: 14),
                  _statChip(
                    Icons.timer_outlined,
                    formatDuration(seconds),
                    "TIME",
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  ElevatedButton.icon(

                    onPressed: () { SoundService.instance.playClick(); showDiskSelector(); },

                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.white70,
                    ),

                    label: const Text(
                      "Play",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.white.withOpacity(0.08),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),

                      side: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton.icon(

                    onPressed: () { SoundService.instance.playClick(); resetGame(); },

                    icon: const Icon(
                      Icons.restart_alt,
                      color: Colors.white70,
                    ),

                    label: const Text(
                      "Restart",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.white.withOpacity(0.08),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),

                      side: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton.icon(

                    onPressed: () { SoundService.instance.playClick(); autoSolve(); },

                    icon: const Icon(
                      Icons.auto_mode,
                      color: Colors.white70,
                    ),

                    label: const Text(
                      "Auto Solve",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.white.withOpacity(0.08),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),

                      side: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),

                ],
              ),

              ElevatedButton.icon(

                onPressed: () { SoundService.instance.playClick(); togglePause(); },

                icon: Icon(
                  isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white70,
                ),

                label: Text(
                  isPaused ? "Resume" : "Pause",
                  style: const TextStyle(color: Colors.white70),
                ),

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.white.withOpacity(0.08),

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),

                  side: BorderSide(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),

              ),
              const SizedBox(height: 30),

              Expanded(

                child: Row(

                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,

                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,

                  children: [

                    Flexible(
                      child: rod("A", rodA),
                    ),

                    Flexible(
                      child: rod("B", rodB),
                    ),

                    Flexible(
                      child: rod("C", rodC),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}
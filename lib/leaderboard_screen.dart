import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/sound_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;

  final Map<int, int> bestMoves = {

    3: 7,
    4: 15,
    5: 31,
    6: 63,
    7: 127,
    8: 255,
  };
  @override
  void initState() {
    super.initState();
    SoundService.instance.playChime();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF11012C),
        elevation: 10,
foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            SoundService.instance.playClick();
            Navigator.pop(context); // back to HanoiScreen
          },
        ),

        title: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: const Text(
                  "Leaderboard",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),

      body: FadeTransition(
        opacity: _fade,

        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("players")
              .snapshots(),

          builder: (context, snapshot) {

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.redAccent,
                ),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No Players Found",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                ),
              );
            }

            final players = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: players.length,

              itemBuilder: (context, index) {
                final data =
                players[index].data()
                as Map<String, dynamic>;

                final completed = data["completed"];

                return AnimatedContainer(
                  duration: Duration(
                      milliseconds: 300 + index * 100),

                  margin: const EdgeInsets.only(bottom: 18),

                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        // PLAYER NAME
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor:
                              Colors.grey,
                              child: Icon(Icons.person,
                                  color: Colors.white),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                data["playerName"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // HEADER
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.orangeAccent,
                                Colors.red
                              ],
                            ),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text("DISKS",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                      FontWeight.bold)),
                              Text("STATUS",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                      FontWeight.bold)),
                            ],
                          ),


                        ),

                        const SizedBox(height: 12),

                        // LEVELS
                        ...[3, 4, 5, 6, 7, 8].map((disk) {
                          // bool done =
                          //     completed["$disk"] ?? false;
                          bool done = completed["$disk"] == true;
                          bool bestDone = completed["${disk}_best"] == true;
                          // bool bestDone =
                          // completed.containsKey("${disk}_best")
                          //     ? completed["${disk}_best"] == true
                          //     : false;

                          int bestMove = bestMoves[disk]!;
                          return AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 300),

                            margin:
                            const EdgeInsets.only(bottom: 10),

                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14),

                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius:
                              BorderRadius.circular(16),
                              border: Border.all(
                                color: done
                                    ? Colors.green
                                    : Colors.orange,
                                width: 1,
                              ),
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Text(
                                  "$disk Disks",
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [

                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: done ? Colors.green : Colors.redAccent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        done ? "DONE" : "PENDING",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    if (bestDone)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "$bestMove BEST MOVES DONE",
                                          style: const TextStyle(
                                            color: Colors.pink,
                                           fontStyle: FontStyle.italic,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

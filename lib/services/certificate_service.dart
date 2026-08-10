import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Every disk-count level the game has.
const List<int> gameLevels = [3, 4, 5, 6, 7, 8];

/// Converts a raw seconds count into a readable duration string.
/// 45 -> "45s", 125 -> "2:05", 3725 -> "1:02:05"
String formatDuration(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  if (hours > 0) {
    return "${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  } else if (minutes > 0) {
    return "${minutes.toString()}:${seconds.toString().padLeft(2, '0')}";
  } else {
    return "${seconds}s";
  }
}

/// A single level's result — did the player complete it, and did they do it
/// in the minimum possible moves.
class LevelStat {
  final int diskCount;
  final bool completed;
  final bool isBest;
  final int moves;
  final int seconds;

  LevelStat({
    required this.diskCount,
    required this.completed,
    required this.isBest,
    required this.moves,
    required this.seconds,
  });

  int get minimumMoves => (1 << diskCount) - 1;
}

/// The single mastery certificate for one player, covering every level.
/// Download/Share only unlock once every level is completed AND every
/// level was completed in the minimum possible moves.
class MasterCertificateData {
  final String certId;
  final String playerName;
  final List<LevelStat> levels;
  final DateTime date;

  MasterCertificateData({
    required this.certId,
    required this.playerName,
    required this.levels,
    required this.date,
  });

  bool get allCompleted => levels.every((l) => l.completed);
  bool get allBest => levels.every((l) => l.isBest);
  bool get isFullyComplete => allCompleted && allBest;

  int get completedCount => levels.where((l) => l.completed).length;
  int get bestCount => levels.where((l) => l.isBest).length;
}

class CertificateService {
  static final CollectionReference _players =
      FirebaseFirestore.instance.collection("players");

  static String _generateCertId(String uid) {
    final h = uid.hashCode.abs().toString().padLeft(8, '0');
    return "HANOI-${h.substring(0, 8)}";
  }

  /// Call this right after a level is won. Merges this level's result into
  /// the player's backend record and makes sure they have a stable,
  /// verifiable certificate ID.
  static Future<void> recordLevelCompletion({
    required int diskCount,
    required int moves,
    required int seconds,
    required bool isBest,
    required String playerName,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _players.doc(uid);
    final snap = await docRef.get();
    final existing = snap.data() as Map<String, dynamic>?;

    final certId = (existing != null && existing["certId"] != null)
        ? existing["certId"] as String
        : _generateCertId(uid);

    await docRef.set({
      "playerName": playerName,
      "certId": certId,
      "stats": {
        "$diskCount": {
          "moves": moves,
          "seconds": seconds,
          "isBest": isBest,
        },
      },
    }, SetOptions(merge: true));
  }

  /// Fetches the currently signed-in player's certificate data (their
  /// progress across all 6 levels, whether or not it's fully unlocked yet).
  static Future<MasterCertificateData?> fetchMyCertificate() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _players.doc(uid).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  /// Public verification: look up any certificate by its printed ID.
  /// Returns null if no certificate with that ID exists.
  static Future<MasterCertificateData?> verifyCertificate(
      String certId) async {
    final trimmed = certId.trim().toUpperCase();
    if (trimmed.isEmpty) return null;

    final query =
        await _players.where("certId", isEqualTo: trimmed).limit(1).get();
    if (query.docs.isEmpty) return null;
    return _fromDoc(query.docs.first);
  }

  static MasterCertificateData _fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final completed = (data["completed"] as Map?) ?? {};
    final stats = (data["stats"] as Map?) ?? {};

    final levels = gameLevels.map((d) {
      final s = (stats["$d"] as Map?) ?? {};
      return LevelStat(
        diskCount: d,
        completed: completed["$d"] ?? false,
        isBest: completed["${d}_best"] ?? false,
        moves: s["moves"] ?? 0,
        seconds: s["seconds"] ?? 0,
      );
    }).toList();

    return MasterCertificateData(
      certId: data["certId"] ?? "UNKNOWN",
      playerName: data["playerName"] ?? "Player",
      levels: levels,
      date: DateTime.now(),
    );
  }

  // ==========================================================
  // PDF GENERATION
  // ==========================================================

  static Future<Uint8List> generatePdf(MasterCertificateData data) async {
    final doc = pw.Document();

    final brown = PdfColor.fromHex("#5C3A21");
    final darkBrown = PdfColor.fromHex("#3E2712");
    final gold = PdfColor.fromHex("#B8860B");
    final cream = PdfColor.fromHex("#FFFDF8");
    final grey = PdfColor.fromHex("#6B6B6B");
    final green = PdfColor.fromHex("#2E7D32");

    final dateStr = DateFormat("MMMM d, y").format(data.date);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) {
          return pw.Container(
            color: cream,
            margin: const pw.EdgeInsets.all(18),
            padding: const pw.EdgeInsets.all(28),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: brown, width: 6),
            ),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: gold, width: 1.2),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(height: 6),
                  pw.Text(
                    "TOWER OF HANOI",
                    style: pw.TextStyle(
                        color: gold, fontSize: 11, letterSpacing: 4),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "MASTERY CERTIFICATE",
                    style: pw.TextStyle(
                      color: darkBrown,
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  pw.SizedBox(height: 14),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Certificate ID: ${data.certId}",
                          style: pw.TextStyle(color: grey, fontSize: 9)),
                      pw.Text("Date: $dateStr",
                          style: pw.TextStyle(color: grey, fontSize: 9)),
                    ],
                  ),
                  pw.SizedBox(height: 22),
                  pw.Text("THIS CERTIFIES THAT",
                      style: pw.TextStyle(
                          color: grey, fontSize: 10, letterSpacing: 2)),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    data.playerName,
                    style: pw.TextStyle(
                      color: darkBrown,
                      fontSize: 30,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    "has completed every level of the Tower of Hanoi (3 through 8 disks) "
                    "and solved each one in the minimum possible number of moves, "
                    "demonstrating full mastery of the recursive puzzle.",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(color: grey, fontSize: 10.5),
                  ),
                  pw.SizedBox(height: 20),

                  // Level breakdown table
                  pw.Table(
                    border: pw.TableBorder.all(color: gold, width: 0.6),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: brown),
                        children: [
                          _cell("DISKS", cream, bold: true),
                          _cell("MOVES", cream, bold: true),
                          _cell("MIN MOVES", cream, bold: true),
                          _cell("TIME", cream, bold: true),
                          _cell("RESULT", cream, bold: true),
                        ],
                      ),
                      for (final l in data.levels)
                        pw.TableRow(
                          children: [
                            _cell("${l.diskCount}", darkBrown),
                            _cell("${l.moves}", darkBrown),
                            _cell("${l.minimumMoves}", darkBrown),
                            _cell(formatDuration(l.seconds), darkBrown),
                            _cell(
                              l.isBest
                                  ? "BEST"
                                  : (l.completed ? "DONE" : "-"),
                              l.isBest ? green : darkBrown,
                              bold: l.isBest,
                            ),
                          ],
                        ),
                    ],
                  ),

                  pw.SizedBox(height: 20),
                  pw.Text(
                    '"Every great achievement was once considered impossible."',
                    style: pw.TextStyle(
                      color: grey,
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),

                  pw.SizedBox(height: 22),
                  pw.Divider(color: gold, thickness: 0.5),
                  pw.SizedBox(height: 14),

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("IQRA KHAWAR",
                              style: pw.TextStyle(
                                  color: darkBrown,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text("Manager",
                              style:
                                  pw.TextStyle(color: grey, fontSize: 9)),
                          pw.Text(
                            "Software Engineer & Deep Learning Engineer",
                            style:
                                pw.TextStyle(color: grey, fontSize: 8),
                          ),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.BarcodeWidget(
                            barcode: pw.Barcode.qrCode(),
                            data: data.certId,
                            width: 60,
                            height: 60,
                            color: darkBrown,
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text("Scan to verify",
                              style:
                                  pw.TextStyle(color: grey, fontSize: 7)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _cell(String text, PdfColor color, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static Future<File> downloadPdf(MasterCertificateData data) async {
    final bytes = await generatePdf(data);
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        "TowerOfHanoi_MasteryCertificate_${data.certId}.pdf";
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> sharePdf(MasterCertificateData data) async {
    final bytes = await generatePdf(data);
    final fileName = "TowerOfHanoi_MasteryCertificate_${data.certId}.pdf";
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }
}

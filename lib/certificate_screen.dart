import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'SplashScreen.dart';
import 'services/certificate_service.dart';
import 'services/sound_service.dart';
import 'verify_certificate_screen.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  late Future<MasterCertificateData?> _future;
  bool _busy = false;
  bool _wasComplete = false;

  @override
  void initState() {
    super.initState();
    SoundService.instance.playChime();
    _future = CertificateService.fetchMyCertificate();
  }

  Future<void> _download(MasterCertificateData data) async {
    SoundService.instance.playClick();
    setState(() => _busy = true);
    try {
      final file = await CertificateService.downloadPdf(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          content: Text("Saved to ${file.path}"),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text("Download failed: $e"),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(MasterCertificateData data) async {
    SoundService.instance.playClick();
    setState(() => _busy = true);
    try {
      await CertificateService.sharePdf(data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text("Share failed: $e"),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11012C),
        foregroundColor: Colors.white,
        elevation: 10,
        title: const Text(
          "Mastery Certificate",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            tooltip: "Verify a certificate",
            onPressed: () {
              SoundService.instance.playClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VerifyCertificateScreen(),
                ),
              );
            },
            icon: const Icon(Icons.verified_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          const DotBackground(),
          FutureBuilder<MasterCertificateData?>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                );
              }

              final data = snapshot.data;
              if (data == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "Play a level to start building your certificate!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  ),
                );
              }

              if (!_wasComplete && data.isFullyComplete) {
                _wasComplete = true;
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => SoundService.instance.playUnlock());
              }

              if (!data.isFullyComplete) {
                return _buildProgressView(data, gold);
              }

              return _buildCertificateView(data);
            },
          ),
          if (_busy)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressView(MasterCertificateData data, Color gold) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Icon(Icons.lock_outline, color: Colors.white38, size: 48),
          const SizedBox(height: 14),
          const Text(
            "Certificate Locked",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Complete every level (3-8 disks) in the minimum number of moves "
            "to unlock your Mastery Certificate.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
          ),
          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _progressStat(
                  "${data.completedCount}/6",
                  "Levels completed",
                  Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _progressStat(
                  "${data.bestCount}/6",
                  "Best moves achieved",
                  gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          ...data.levels.map((l) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Text(
                    "${l.diskCount} Disks",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Icon(
                    l.completed ? Icons.check_circle : Icons.circle_outlined,
                    color: l.completed ? Colors.greenAccent : Colors.white24,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text("Done",
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(width: 16),
                  Icon(
                    l.isBest ? Icons.workspace_premium : Icons.circle_outlined,
                    color: l.isBest ? gold : Colors.white24,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text("Best",
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Download & Share unlock automatically once all 6 levels\nshow both checkmarks.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressStat(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCertificateView(MasterCertificateData data) {
    final gold = const Color(0xFFD4AF37);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PdfPreview(
                build: (format) => CertificateService.generatePdf(data),
                canChangePageFormat: false,
                canChangeOrientation: false,
                allowPrinting: true,
                allowSharing: false,
                useActions: false,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : () => _download(data),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text("Download"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.10),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.15)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : () => _share(data),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text("Share"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

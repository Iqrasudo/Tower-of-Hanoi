import 'package:flutter/material.dart';

import 'SplashScreen.dart';
import 'services/certificate_service.dart';
import 'services/sound_service.dart';

class VerifyCertificateScreen extends StatefulWidget {
  const VerifyCertificateScreen({super.key});

  @override
  State<VerifyCertificateScreen> createState() =>
      _VerifyCertificateScreenState();
}

class _VerifyCertificateScreenState extends State<VerifyCertificateScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  bool _searched = false;
  MasterCertificateData? _result;

  Future<void> _verify() async {
    SoundService.instance.playClick();
    final id = _controller.text.trim();
    if (id.isEmpty) return;

    setState(() {
      _loading = true;
      _searched = true;
    });

    final result = await CertificateService.verifyCertificate(id);

    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });

    if (result != null && result.isFullyComplete) {
      SoundService.instance.playUnlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11012C),
        foregroundColor: Colors.white,
        elevation: 10,
        title: const Text(
          "Verify Certificate",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: Stack(
        children: [
          const DotBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Icon(Icons.verified_outlined,
                    color: Colors.amber, size: 44),
                const SizedBox(height: 12),
                const Text(
                  "Check any Tower of Hanoi certificate",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Enter the Certificate ID printed on the document\n(e.g. HANOI-A1B2C3D4)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Certificate ID",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.badge_outlined, color: Colors.white38),
                  ),
                  onSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: 14),

                ElevatedButton.icon(
                  onPressed: _loading ? null : _verify,
                  icon: const Icon(Icons.search),
                  label: const Text("Verify"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  ),

                if (!_loading && _searched) _buildResult(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    if (_result == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
        ),
        child: const Column(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 30),
            SizedBox(height: 8),
            Text(
              "Not a valid certificate",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "No certificate exists with this ID.",
              style: TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final data = _result!;
    final ok = data.isFullyComplete;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: (ok ? Colors.green : Colors.amber).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (ok ? Colors.green : Colors.amber).withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.hourglass_bottom,
            color: ok ? Colors.greenAccent : Colors.amber,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            ok ? "Verified — Genuine Certificate" : "Player found, not yet complete",
            style: TextStyle(
              color: ok ? Colors.greenAccent : Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _row("Player", data.playerName),
          _row("Certificate ID", data.certId),
          _row("Levels completed", "${data.completedCount}/6"),
          _row("Best-move levels", "${data.bestCount}/6"),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

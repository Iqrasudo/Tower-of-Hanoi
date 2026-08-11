import 'package:audioplayers/audioplayers.dart';

/// Centralized sound effect player for the game.
///
/// Usage:
///   SoundService.instance.playMove();
///   SoundService.instance.playInvalid();
///   SoundService.instance.playWin();
///
/// Call SoundService.instance.toggleMute() to mute/unmute globally
/// (e.g. from a settings/mute button in the UI).
class SoundService {
  SoundService._internal();

  static final SoundService instance = SoundService._internal();

  final AudioPlayer _movePlayer = AudioPlayer();
  final AudioPlayer _invalidPlayer = AudioPlayer();
  final AudioPlayer _winPlayer = AudioPlayer();
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _chimePlayer = AudioPlayer();
  final AudioPlayer _unlockPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  bool isMuted = false;
  bool _ambientStarted = false;

  Future<void> init() async {
    await _movePlayer.setPlayerMode(PlayerMode.lowLatency);
    await _invalidPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _winPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _clickPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _chimePlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _unlockPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _ambientPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _ambientPlayer.setVolume(0.18);
  }

  /// Starts the soft looping ambient sound behind the falling dots.
  /// Safe to call from every screen's initState — it only actually starts
  /// once and just keeps looping quietly across navigation.
  Future<void> startAmbient() async {
    if (_ambientStarted || isMuted) return;
    _ambientStarted = true;
    try {
      await _ambientPlayer.play(AssetSource('sounds/ambient.wav'));
    } catch (_) {
      _ambientStarted = false;
    }
  }

  Future<void> stopAmbient() async {
    _ambientStarted = false;
    try {
      await _ambientPlayer.stop();
    } catch (_) {}
  }

  void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      _ambientPlayer.pause();
    } else {
      if (_ambientStarted) {
        _ambientPlayer.resume();
      } else {
        startAmbient();
      }
    }
  }

  /// Soft UI tap sound — use on every button press across every screen.
  Future<void> playClick() async {
    if (isMuted) return;
    try {
      await _clickPlayer.stop();
      await _clickPlayer.play(AssetSource('sounds/click.wav'));
    } catch (_) {}
  }

  /// Gentle chime — use when a new screen opens.
  Future<void> playChime() async {
    if (isMuted) return;
    try {
      await _chimePlayer.stop();
      await _chimePlayer.play(AssetSource('sounds/chime.wav'));
    } catch (_) {}
  }

  /// Rising unlock jingle — use when the mastery certificate unlocks.
  Future<void> playUnlock() async {
    if (isMuted) return;
    try {
      await _unlockPlayer.stop();
      await _unlockPlayer.play(AssetSource('sounds/unlock.wav'));
    } catch (_) {}
  }

  Future<void> playMove() async {
    if (isMuted) return;
    try {
      await _movePlayer.stop();
      await _movePlayer.play(AssetSource('sounds/move.wav'));
    } catch (_) {
      // Never let a sound failure break gameplay.
    }
  }

  Future<void> playInvalid() async {
    if (isMuted) return;
    try {
      await _invalidPlayer.stop();
      await _invalidPlayer.play(AssetSource('sounds/invalid.wav'));
    } catch (_) {}
  }

  Future<void> playWin() async {
    if (isMuted) return;
    try {
      await _winPlayer.stop();
      await _winPlayer.play(AssetSource('sounds/win.wav'));
    } catch (_) {}
  }

  void dispose() {
    _movePlayer.dispose();
    _invalidPlayer.dispose();
    _winPlayer.dispose();
    _clickPlayer.dispose();
    _chimePlayer.dispose();
    _unlockPlayer.dispose();
    _ambientPlayer.dispose();
  }
}

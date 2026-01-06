import 'package:just_audio/just_audio.dart';

enum SoundType {
  shutter,
  tick,
  success,
  milestone,
}

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final Map<SoundType, AudioPlayer> _players = {};
  bool _isEnabled = true;
  double _volume = 1.0;

  bool get isEnabled => _isEnabled;
  double get volume => _volume;

  Future<void> initialize() async {
    // Initialize audio players for each sound type
    // Note: Sound files need to be added to assets/sounds/
    for (final soundType in SoundType.values) {
      final player = AudioPlayer();
      _players[soundType] = player;

      // Preload sounds (when assets are available)
      try {
        await _loadSound(soundType, player);
      } catch (e) {
        // Sound file not found - will be added later
        // ignore: avoid_print
        print('Sound file not found for $soundType: $e');
      }
    }
  }

  Future<void> _loadSound(SoundType soundType, AudioPlayer player) async {
    final soundPath = _getSoundPath(soundType);
    await player.setAsset(soundPath);
    await player.setVolume(_volume);
    await player.load();
  }

  String _getSoundPath(SoundType soundType) {
    switch (soundType) {
      case SoundType.shutter:
        return 'assets/sounds/shutter.mp3';
      case SoundType.tick:
        return 'assets/sounds/tick.mp3';
      case SoundType.success:
        return 'assets/sounds/success.mp3';
      case SoundType.milestone:
        return 'assets/sounds/milestone.mp3';
    }
  }

  Future<void> play(SoundType soundType) async {
    if (!_isEnabled) return;

    final player = _players[soundType];
    if (player == null) return;

    try {
      // Seek to start and play
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      // Sound not loaded or error playing
      // ignore: avoid_print
      print('Error playing sound $soundType: $e');
    }
  }

  Future<void> playShutter() async {
    await play(SoundType.shutter);
  }

  Future<void> playTick() async {
    await play(SoundType.tick);
  }

  Future<void> playSuccess() async {
    await play(SoundType.success);
  }

  Future<void> playMilestone() async {
    await play(SoundType.milestone);
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    for (final player in _players.values) {
      await player.setVolume(_volume);
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}

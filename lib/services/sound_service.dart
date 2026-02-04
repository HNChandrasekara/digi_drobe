import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _muted = false;

  /// Play an asset sound from `assets/sounds/<name>`
  static Future<void> playAsset(String assetName) async {
    if (_muted) return;
    try {
      await _player.play(AssetSource('sounds/$assetName'));
    } catch (_) {}
  }

  static Future<void> playClick() => playAsset('click.mp3');

  static void setMuted(bool muted) => _muted = muted;
}

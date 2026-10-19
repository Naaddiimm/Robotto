import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  /// Play standard button tap feedback
  static Future<void> playClickSound() async {
    try {
      // Trigger native system haptic/click sound
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Play futuristic success tone for primary action
  static Future<void> playSuccessSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.mediumImpact();
      // Play crisp sci-fi beep sound
      await _player.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3'));
    } catch (_) {}
  }

  /// Play card tap sound
  static Future<void> playCardTapSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}

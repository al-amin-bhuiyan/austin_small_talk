import 'dart:async';

import 'package:audio_session/audio_session.dart';

class AudioSessionConfigHelper {
  static Future<void> configureForVoiceChat() async {
    print('🔊 Configuring audio session...');

    try {
      // Add timeout to prevent infinite blocking
      await Future.any([
        _configureAudioSession(),
        Future.delayed(Duration(seconds: 3), () {
          throw TimeoutException('Audio session configuration timed out');
        }),
      ]);

      print('✅ Audio session configured (speaker mode enabled)');
    } catch (e) {
      print('⚠️ Audio session configuration failed (continuing anyway): $e');
      // Don't rethrow - audio session config failure shouldn't block voice chat
    }
  }

  static Future<void> _configureAudioSession() async {
    print('   Getting AudioSession instance...');
    final session = await AudioSession.instance;

    print('   Applying configuration...');
    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
        AVAudioSessionCategoryOptions.allowBluetooth |
        AVAudioSessionCategoryOptions.duckOthers |
        AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        avAudioSessionRouteSharingPolicy:
        AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ),
    );

    print('   Activating session...');
    await session.setActive(true);
  }
}

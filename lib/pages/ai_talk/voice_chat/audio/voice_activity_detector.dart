import 'dart:typed_data';
import 'dart:math';

/// Simple Voice Activity Detector for Flutter
/// Provided by AI Developer for improved speech detection
class SimpleVAD {

  double noiseFloor = 500.0;  // REDUCED from 1000.0
  final List<double> energyHistory = [];
  final int historySize = 10;
  final double thresholdMultiplier = 2.5;  // REDUCED from 2.5

  /// Check if audio frame contains speech
  /// Returns true if speech is detected
  bool isSpeech(Uint8List audioFrame) {
    // Convert bytes to Int16 samples
    final int16List = Int16List.view(audioFrame.buffer);

    if (int16List.isEmpty) return false;

    // Calculate RMS (Root Mean Square)
    double sumSquares = 0;
    for (var sample in int16List) {
      sumSquares += sample * sample;
    }
    double rms = sqrt(sumSquares / int16List.length);

    // Calculate energy
    double sumAbs = 0;
    for (var sample in int16List) {
      sumAbs += sample.abs();
    }
    double energy = sumAbs / int16List.length;

    // Calculate Zero Crossing Rate (ZCR)
    int zeroCrossings = 0;
    for (int i = 1; i < int16List.length; i++) {
      if ((int16List[i - 1] >= 0 && int16List[i] < 0) ||
          (int16List[i - 1] < 0 && int16List[i] >= 0)) {
        zeroCrossings++;
      }
    }
    double zcr = zeroCrossings / int16List.length;

    // Update noise floor using minimum values
    energyHistory.add(rms);
    if (energyHistory.length > historySize) {
      energyHistory.removeAt(0);
    }

    if (energyHistory.length >= 3) {
      final sortedValues = List<double>.from(energyHistory)..sort();
      final minValues = sortedValues.sublist(0, sortedValues.length ~/ 2);
      noiseFloor = minValues.reduce((a, b) => a + b) / minValues.length;
    }

    // Adaptive threshold - ✅ REDUCED minimum threshold
    double threshold = max(noiseFloor * thresholdMultiplier, 200.0);

    // ✅ RELAXED speech detection criteria:
    // 1. RMS above adaptive threshold
    // 2. Zero-crossing rate in wider speech range (0.02 - 0.6)
    // 3. Energy above lower threshold
    bool isSpeechDetected = rms > threshold &&
        zcr > 0.02 && zcr < 0.6 &&
        energy > threshold * 0.3;

    return isSpeechDetected;
  }

  /// Get current noise floor estimate
  double getNoiseFloor() => noiseFloor;

  /// Reset VAD state
  void reset() {
    energyHistory.clear();
    noiseFloor = 500.0;  // ✅ Match reduced initial value
  }
}

/// VAD Processor with hysteresis for stable speech detection
/// Wraps SimpleVAD with confirmation logic
class VoiceActivityDetector {
  final SimpleVAD _vad = SimpleVAD();

  // VAD state
  int silenceFrames = 0;
  int speechFrames = 0;
  int confirmationFrames = 0;
  bool isConfirmedSpeaking = false;

  // ✅ Echo cancellation - track AI speaker state
  bool _isPlayingAudio = false;

  // ✅ REDUCED thresholds for faster detection
  static const int silenceThreshold = 20;  // 300ms at 20ms frames (was 25)
  static const int minSpeechFrames = 15;    // 100ms minimum (was 15)
  static const int hysteresis = 5;         // 40ms confirmation (was 5)

  /// Check if audio frame contains speech (direct)
  bool isSpeech(Uint8List audioFrame) => _vad.isSpeech(audioFrame);

  /// ✅ Set playback state for echo cancellation
  /// Call with true when AI starts speaking, false when finished
  void setPlaybackState(bool isPlaying) {
    if (_isPlayingAudio != isPlaying) {
      _isPlayingAudio = isPlaying;
      print('🔊 VAD: Playback state changed to ${isPlaying ? "PLAYING" : "STOPPED"}');

      // Reset VAD state when playback starts to prevent false triggers
      if (isPlaying) {
        resetState();
      }
    }
  }

  /// Process frame with hysteresis for stable speech detection
  VadResult processFrame(Uint8List frame) {
    // ✅ ECHO CANCELLATION: Suppress VAD during AI playback
    if (_isPlayingAudio) {
      // Return no speech detected while AI is speaking
      return VadResult(
        shouldSend: false,
        speechStarted: false,
        speechEnded: false,
      );
    }

    bool hasSpeech = _vad.isSpeech(frame);

    if (hasSpeech) {
      confirmationFrames++;
      silenceFrames = 0;

      // Confirm speech after hysteresis frames
      if (confirmationFrames >= hysteresis && !isConfirmedSpeaking) {
        isConfirmedSpeaking = true;
        speechFrames = 0;
        print('🎤 VAD: Speech started');
        return VadResult(
          shouldSend: true,
          speechStarted: true,
          speechEnded: false,
        );
      }

      if (isConfirmedSpeaking) {
        speechFrames++;
        return VadResult(shouldSend: true);
      }
    } else {
      confirmationFrames = 0;
      silenceFrames++;

      // ✅ Keep sending for longer during brief silence
      if (isConfirmedSpeaking && silenceFrames < 5) {
        return VadResult(shouldSend: true);
      }

      // Check if we should end speech
      if (isConfirmedSpeaking &&
          silenceFrames >= silenceThreshold &&
          speechFrames >= minSpeechFrames) {
        print('🔇 VAD: Speech ended ($speechFrames frames, $silenceFrames silence)');
        final result = VadResult(
          shouldSend: false,
          speechEnded: true,
        );
        resetState();
        return result;
      }

      // Still in confirmed speech but brief silence
      if (isConfirmedSpeaking) {
        return VadResult(shouldSend: true);
      }
    }

    return VadResult(shouldSend: isConfirmedSpeaking);
  }

  /// Get current noise floor estimate
  double getNoiseFloor() => _vad.getNoiseFloor();

  /// Reset VAD state (keeps noise floor)
  void resetState() {
    silenceFrames = 0;
    speechFrames = 0;
    confirmationFrames = 0;
    isConfirmedSpeaking = false;
  }

  /// Reset completely (including noise floor)
  void reset() {
    resetState();
    _vad.reset();
  }

  /// Alias for reset
  void resetCompletely() => reset();
}

/// Result from VAD processing
class VadResult {
  final bool shouldSend;      // Should this frame be sent to server?
  final bool speechStarted;   // Did speech just start?
  final bool speechEnded;     // Did speech just end?

  VadResult({
    this.shouldSend = false,
    this.speechStarted = false,
    this.speechEnded = false,
  });
}

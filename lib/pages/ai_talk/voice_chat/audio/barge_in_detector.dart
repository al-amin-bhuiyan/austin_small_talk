import 'dart:math';
import 'dart:typed_data';

class BargeInDetector {
  final double baseThreshold;
  final int requiredFrames;
  int _hits = 0;
  double _backgroundNoise = 0.05;
  int _frameCount = 0;

  BargeInDetector({this.baseThreshold = 0.20, this.requiredFrames = 3});

  bool processPcm16Frame(Uint8List pcm16le, {bool isAiSpeaking = false}) {
    if (pcm16le.length < 2) return false;

    final bd = ByteData.sublistView(pcm16le);
    final sampleCount = pcm16le.length ~/ 2;

    double sumSquares = 0;
    double sumWeightedFreq = 0;
    double sumMagnitude = 0;

    for (int i = 0; i < sampleCount; i++) {
      final sample = bd.getInt16(i * 2, Endian.little);
      final normalized = sample / 32768.0;
      sumSquares += normalized * normalized;

      final freqWeight = (i / sampleCount) * normalized.abs();
      sumWeightedFreq += freqWeight;
      sumMagnitude += normalized.abs();
    }

    final rms = sqrt(sumSquares / sampleCount);
    final spectralCentroid = sumMagnitude > 0
        ? sumWeightedFreq / sumMagnitude
        : 0.0;

    // ✅ Adaptive threshold: Higher when AI is speaking
    final adaptiveThreshold = isAiSpeaking
        ? baseThreshold * 2.5
        : baseThreshold;

    // Update background noise estimate
    if (!isAiSpeaking && rms < baseThreshold) {
      _frameCount++;
      if (_frameCount % 20 == 0) {
        _backgroundNoise = (_backgroundNoise * 0.9) + (rms * 0.1);
      }
    }

    final effectiveThreshold = max(adaptiveThreshold, _backgroundNoise * 2.0);
    // ✅ Require higher spectral centroid during AI speech (more likely human)
    final minSpectralCentroid = isAiSpeaking ? 0.35 : 0.25;
    final isLikelyHumanVoice = spectralCentroid >minSpectralCentroid && rms > effectiveThreshold;
    // ✅ Require MORE consecutive frames during AI speech
    final effectiveRequiredFrames = isAiSpeaking ? 5 : requiredFrames;

    if (isLikelyHumanVoice) {
      _hits++;

      if (_hits <= effectiveRequiredFrames) {
        print('🔊 Barge-in hit: $_hits/$requiredFrames (RMS: ${rms.toStringAsFixed(3)}, spectral: ${spectralCentroid.toStringAsFixed(3)})');
      }

      if (_hits >= effectiveRequiredFrames) {
        print('🎯 BARGE-IN DETECTED! Human voice pattern confirmed');
        return true;
      }
    } else {
      if (_hits > 0 && !isLikelyHumanVoice) {
        print('🔇 Non-voice audio detected, resetting counter (spectral: ${spectralCentroid.toStringAsFixed(3)})');
      }
      _hits = 0;
    }

    return false;
  }

  void reset() {
    if (_hits > 0) {
      print('🔄 Barge-in detector reset');
    }
    _hits = 0;
  }
}

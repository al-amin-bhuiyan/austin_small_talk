import 'dart:math';
import 'dart:typed_data';

class BargeInDetector {
  final double threshold; // RMS threshold for detecting speech
  final int requiredFrames; // Consecutive frames needed to confirm barge-in

  int _hits = 0;

  // ✅ Increased default threshold from 0.09 to 0.15 to reduce false positives
  BargeInDetector({this.threshold = 0.15, this.requiredFrames = 3});

  bool processPcm16Frame(Uint8List pcm16le) {
    if (pcm16le.length < 2) return false;

    final bd = ByteData.sublistView(pcm16le);
    final sampleCount = pcm16le.length ~/ 2;

    // Calculate RMS (Root Mean Square) amplitude
    double sumSquares = 0;
    for (int i = 0; i < sampleCount; i++) {
      final sample = bd.getInt16(i * 2, Endian.little);
      final normalized = sample / 32768.0; // Normalize to -1.0 to 1.0
      sumSquares += normalized * normalized;
    }
    final rms = sqrt(sumSquares / sampleCount);

    // Check if amplitude exceeds threshold
    if (rms > threshold) {
      _hits++;
      
      // Log barge-in detection progress
      if (_hits <= requiredFrames) {
        print('🔊 Barge-in hit: $_hits/$requiredFrames (RMS: ${rms.toStringAsFixed(3)}, threshold: ${threshold.toStringAsFixed(3)})');
      }
      
      if (_hits >= requiredFrames) {
        print('🎯 BARGE-IN DETECTED! User is speaking over AI.');
        return true; // Barge-in confirmed
      }
    } else {
      // Reset on silence
      if (_hits > 0) {
        print('🔇 Silence detected, resetting barge-in counter (was: $_hits)');
      }
      _hits = 0;
    }

    return false; // No barge-in yet
  }

  void reset() {
    if (_hits > 0) {
      print('🔄 Barge-in detector reset');
    }
    _hits = 0;
  }
}

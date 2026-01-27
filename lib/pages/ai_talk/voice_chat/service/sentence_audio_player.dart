import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class SentenceAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  // ✅ Sentence buffer - accumulates chunks for current sentence
  final List<Uint8List> _sentenceBuffer = [];

  // ✅ Queue of complete sentences ready to play
  final List<Uint8List> _playbackQueue = [];

  bool _isPlaying = false;
  bool _isStopped = false; // ✅ FIX #6: Track if playback was stopped

  final int _sampleRate;
  final int _channels;
  Directory? _tempDir;

  SentenceAudioPlayer({
    int sampleRate = 24000,
    int channels = 1,
  })  : _sampleRate = sampleRate,
        _channels = channels;

  Future<void> _initTempDir() async {
    _tempDir ??= await getTemporaryDirectory();
  }

  /// ✅ On tts_sentence_start: reset sentence buffer
  void onSentenceStart() {
    // ✅ FIX #6: Reset stop flag on new sentence
    _isStopped = false;
    _sentenceBuffer.clear();
    print('📝 Sentence buffer cleared - new sentence starting');
  }

  /// ✅ On binary: add to sentence buffer
  void addAudioFrame(Uint8List frame) {
    // ✅ FIX #6: Don't add frames if stopped
    if (_isStopped) {
      return;
    }
    
    _sentenceBuffer.add(frame);
    // Only log every 10 frames to reduce noise
    if (_sentenceBuffer.length % 10 == 0) {
      print('📦 Buffering... ${_sentenceBuffer.length} frames');
    }
  }

  /// ✅ On tts_sentence_end: play buffered sentence audio
  Future<void> onSentenceEnd() async {
    // ✅ FIX #6: Don't play if stopped
    if (_isStopped) {
      print('⚠️ Playback stopped - discarding sentence');
      _sentenceBuffer.clear();
      return;
    }
    
    if (_sentenceBuffer.isEmpty) {
      print('⚠️ No audio frames in sentence buffer');
      return;
    }

    // Combine all buffered frames into one sentence audio
    final combinedData = <int>[];
    for (final frame in _sentenceBuffer) {
      combinedData.addAll(frame);
    }

    final sentenceAudio = Uint8List.fromList(combinedData);
    _playbackQueue.add(sentenceAudio);

    print('✅ Sentence buffered: ${_sentenceBuffer.length} frames → ${combinedData.length} bytes | Queue: ${_playbackQueue.length}');

    _sentenceBuffer.clear(); // Clear for next sentence

    // Start playing if not already playing
    if (!_isPlaying && !_isStopped) {
      await _playBufferedAudio();
    }
  }

  /// Play buffered sentence audio from queue
  Future<void> _playBufferedAudio() async {
    // ✅ FIX #6: Check stopped state
    if (_isPlaying || _playbackQueue.isEmpty || _isStopped) return;

    _isPlaying = true;
    final sentenceAudio = _playbackQueue.removeAt(0);

    try {
      await _initTempDir();

      // Convert PCM to WAV
      final wavData = _addWavHeader(sentenceAudio, _sampleRate, _channels, 16);

      // Save to temp file
      final file = File('${_tempDir!.path}/sentence_${DateTime.now().millisecondsSinceEpoch}.wav');
      await file.writeAsBytes(wavData);

      print('🔊 Playing sentence (${sentenceAudio.length} bytes) | ${_playbackQueue.length} in queue');

      // ✅ FIX #6: Check stopped before playing
      if (_isStopped) {
        _isPlaying = false;
        await _deleteFile(file);
        return;
      }

      // Play the sentence
      await _player.play(DeviceFileSource(file.path));

      // Wait for completion with timeout
      try {
        await _player.onPlayerComplete.first.timeout(
          Duration(seconds: 30), // Max 30 seconds per sentence
          onTimeout: () {
            print('⚠️ Playback timeout - moving to next');
          },
        );
      } catch (e) {
        print('⚠️ Playback wait error: $e');
      }

      print('✅ Sentence playback finished');

      // Cleanup
      await _deleteFile(file);

      _isPlaying = false;

      // ✅ FIX #6: Check stopped before playing next
      if (!_isStopped && _playbackQueue.isNotEmpty) {
        await _playBufferedAudio();
      }

    } catch (e) {
      print('❌ Playback error: $e');
      _isPlaying = false;

      // ✅ FIX #6: Only try next if not stopped
      if (!_isStopped && _playbackQueue.isNotEmpty) {
        await Future.delayed(Duration(milliseconds: 100));
        await _playBufferedAudio();
      }
    }
  }

  /// ✅ FIX #6: Helper to safely delete temp file
  Future<void> _deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore delete errors
    }
  }

  /// Check if still has audio to play
  bool get hasFrames => !_isStopped && (_playbackQueue.isNotEmpty || _isPlaying || _sentenceBuffer.isNotEmpty);

  /// Clear all buffers (but don't stop current playback)
  void clear() {
    _sentenceBuffer.clear();
    _playbackQueue.clear();
    print('🧹 Buffers cleared');
  }

  /// ✅ FIX #6: Stop playback completely
  Future<void> stop() async {
    print('🛑 Stopping audio player...');
    _isStopped = true;
    _isPlaying = false;
    
    // Stop the player
    try {
      await _player.stop();
    } catch (e) {
      print('⚠️ Player stop error: $e');
    }
    
    // Clear all buffers
    _sentenceBuffer.clear();
    _playbackQueue.clear();
    
    print('✅ Audio player stopped');
  }

  /// Add WAV header to PCM data
  Uint8List _addWavHeader(
      Uint8List pcmData,
      int sampleRate,
      int channels,
      int bitsPerSample,
      ) {
    final byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
    final blockAlign = channels * (bitsPerSample ~/ 8);
    final header = ByteData(44);

    // RIFF
    header.setUint8(0, 0x52); header.setUint8(1, 0x49);
    header.setUint8(2, 0x46); header.setUint8(3, 0x46);
    header.setUint32(4, 36 + pcmData.length, Endian.little);
    header.setUint8(8, 0x57); header.setUint8(9, 0x41);
    header.setUint8(10, 0x56); header.setUint8(11, 0x45);

    // fmt
    header.setUint8(12, 0x66); header.setUint8(13, 0x6D);
    header.setUint8(14, 0x74); header.setUint8(15, 0x20);
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);

    // data
    header.setUint8(36, 0x64); header.setUint8(37, 0x61);
    header.setUint8(38, 0x74); header.setUint8(39, 0x61);
    header.setUint32(40, pcmData.length, Endian.little);

    final wav = Uint8List(44 + pcmData.length);
    wav.setRange(0, 44, header.buffer.asUint8List());
    wav.setRange(44, 44 + pcmData.length, pcmData);

    return wav;
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
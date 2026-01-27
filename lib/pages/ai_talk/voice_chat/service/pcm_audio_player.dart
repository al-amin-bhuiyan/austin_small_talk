import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class PcmAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  final List<Uint8List> _frames = [];
  bool _isPlaying = false;
  int _sampleRate;
  int _channels;

  // ✅ Buffer threshold - wait for 3 frames (~60ms) before playing
  final int _bufferThresholdFrames = 3;
  final int _framesPerChunk = 3; // Combine 3 frames into one playback chunk

  Directory? _tempDir;

  PcmAudioPlayer({
    int sampleRate = 24000,
    int channels = 1,
  })  : _sampleRate = sampleRate,
        _channels = channels;

  Future<void> _initTempDir() async {
    _tempDir ??= await getTemporaryDirectory();
  }

  /// ✅ Check if still has frames to play
  bool get hasFrames => _frames.isNotEmpty || _isPlaying;

  /// Add frame (called for each audio chunk from server)
  Future<void> addAndPlayChunk(Uint8List frame) async {
    if (frame.isEmpty) return;

    _frames.add(frame);

    // Start playing once we have enough buffered frames
    if (!_isPlaying && _frames.length >= _bufferThresholdFrames) {
      print('▶️ Buffer ready (${_frames.length} frames) - starting playback');
      _isPlaying = true;
      _playBufferedAudio();
    }
  }

  /// Play buffered audio chunks
  Future<void> _playBufferedAudio() async {
    await _initTempDir();

    while (_frames.isNotEmpty) {
      try {
        // ✅ Combine 3 frames into one chunk for smoother playback
        List<Uint8List> chunk = [];
        for (int i = 0; i < _framesPerChunk && _frames.isNotEmpty; i++) {
          chunk.add(_frames.removeAt(0));
        }

        // Combine frames
        final combined = Uint8List.fromList(
            chunk.expand((frame) => frame).toList()
        );

        // Convert to WAV
        final wavData = _addWavHeader(combined, _sampleRate, _channels, 16);

        // Save and play
        final file = File('${_tempDir!.path}/chunk_${DateTime.now().microsecondsSinceEpoch}.wav');
        await file.writeAsBytes(wavData);

        print('🎵 Playing ${chunk.length} frames (${combined.length}B) | ${_frames.length} remaining');

        // Play chunk
        await _player.play(DeviceFileSource(file.path));

        // Wait for completion
        await _player.onPlayerComplete.first;

        // Delete file
        try {
          await file.delete();
        } catch (e) {}

        // ✅ Slight delay to match real-time playback (prevent too fast playback)
        if (_frames.isNotEmpty) {
          await Future.delayed(Duration(milliseconds: 10));
        }

      } catch (e) {
        print('❌ Playback error: $e');
        await Future.delayed(Duration(milliseconds: 50));
      }
    }

    _isPlaying = false;
    print('✅ All frames played');
  }

  /// Clear buffer
  void clear() {
    _frames.clear();
    _isPlaying = false;
    print('🧹 Buffer cleared');
  }

  /// Stop playback
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _frames.clear();
  }

  /// Add WAV header
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
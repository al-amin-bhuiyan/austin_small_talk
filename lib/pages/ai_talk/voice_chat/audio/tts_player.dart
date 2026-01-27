import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

/// TTS Player - SAFE implementation using audioplayers
/// WAV file-based playback (no native crashes)
class TtsPlayer {
  final AudioPlayer _player = AudioPlayer();
  final List<Uint8List> _buffer = [];
  bool _isInitialized = false;
  bool _isPlaying = false;
  Directory? _tempDir;
  int _frameCount = 0;

  final int sampleRate;
  final int numChannels;

  TtsPlayer({this.sampleRate = 24000, this.numChannels = 1});

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _tempDir = await getTemporaryDirectory();
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);

      _isInitialized = true;
      print('✅ TTS Player initialized (SAFE mode - audioplayers)');
    } catch (e) {
      print('❌ TTS Player init failed: $e');
      rethrow;
    }
  }

  void addFrame(Uint8List pcmFrame) {
    if (!_isInitialized) return;

    _buffer.add(pcmFrame);
    _frameCount++;

    if (_frameCount % 10 == 0) {
      print('🔊 Buffered $_frameCount frames');
    }
  }

  void onSentenceStart() {
    print('📝 Sentence start');
    _buffer.clear();
  }

  void onSentenceEnd() {
    print('✅ Sentence end - playing audio');
    _playBufferedAudio();
  }

  Future<void> _playBufferedAudio() async {
    if (_buffer.isEmpty || _isPlaying || !_isInitialized) return;

    _isPlaying = true;
    try {
      final combinedData = <int>[];
      for (final frame in _buffer) {
        combinedData.addAll(frame);
      }
      _buffer.clear();

      final wavData = _addWavHeader(Uint8List.fromList(combinedData));
      final tempFile = File('${_tempDir!.path}/tts_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(wavData);

      print('🔊 Playing ${wavData.length} bytes');
      await _player.play(DeviceFileSource(tempFile.path));

      await _player.onPlayerComplete.first.timeout(
        Duration(seconds: 10),
        onTimeout: () => print('⚠️ Playback timeout'),
      );

      try { await tempFile.delete(); } catch (_) {}
    } catch (e) {
      print('❌ Playback error: $e');
    } finally {
      _isPlaying = false;
    }
  }

  Uint8List _addWavHeader(Uint8List pcmData) {
    final byteRate = sampleRate * numChannels * 2;
    final blockAlign = numChannels * 2;
    final header = ByteData(44);

    // RIFF
    header.setUint32(0, 0x52494646, Endian.big);
    header.setUint32(4, 36 + pcmData.length, Endian.little);
    header.setUint32(8, 0x57415645, Endian.big);
    // fmt
    header.setUint32(12, 0x666D7420, Endian.big);
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, 16, Endian.little);
    // data
    header.setUint32(36, 0x64617461, Endian.big);
    header.setUint32(40, pcmData.length, Endian.little);

    return Uint8List.fromList([...header.buffer.asUint8List(), ...pcmData]);
  }

  void clear() => _buffer.clear();

  Future<void> stop() async {
    _isPlaying = false;
    await _player.stop();
    _buffer.clear();
  }

  Future<void> dispose() async {
    _isInitialized = false;
    await stop();
    await _player.dispose();
  }
}

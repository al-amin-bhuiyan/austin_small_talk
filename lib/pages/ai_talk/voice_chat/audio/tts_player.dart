import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

/// TTS Player - SAFE implementation using audioplayers
/// WAV file-based playback (no native crashes)
/// Auto-plays audio when enough frames are buffered
class TtsPlayer {
  final AudioPlayer _player = AudioPlayer();
  final List<Uint8List> _buffer = [];
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isDisposing = false;
  Directory? _tempDir;
  int _frameCount = 0;
  int _fileCounter = 0;
  Timer? _playbackTimer;

  final int sampleRate;
  final int numChannels;

  // ✅ Lower threshold: Server sends 960 bytes/chunk at 24kHz
  // 10 chunks = ~200ms buffer before auto-play starts
  static const int _autoPlayThreshold = 10;

  // ✅ Playback check interval
  static const Duration _playbackCheckInterval = Duration(milliseconds: 50);

  TtsPlayer({this.sampleRate = 24000, this.numChannels = 1});

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _tempDir = await getTemporaryDirectory();

      // Configure audio player
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1.0);

      // Listen for playback completion
      _player.onPlayerComplete.listen((_) {
        print('🔊 Playback complete');
        _isPlaying = false;
        // Check if more audio is buffered
        if (_buffer.isNotEmpty) {
          _playBufferedAudio();
        }
      });

      _isInitialized = true;
      print('✅ TTS Player initialized (${sampleRate}Hz, $numChannels ch)');
    } catch (e) {
      print('❌ TTS Player init failed: $e');
    }
  }

  void addFrame(Uint8List pcmFrame) {
    if (!_isInitialized || _isDisposing) {
      print('⚠️ TtsPlayer not ready, dropping frame');
      return;
    }

    _buffer.add(pcmFrame);
    _frameCount++;

    if (_frameCount % 10 == 0) {
      print('🔊 TTS Buffer: $_frameCount frames (${(_frameCount * pcmFrame.length / 1024).toStringAsFixed(1)} KB)');
    }

    // ✅ AUTO-PLAY: Start playback when we have enough buffered audio
    if (_buffer.length >= _autoPlayThreshold && !_isPlaying) {
      print('▶️ Auto-play threshold reached, starting playback...');
      _playBufferedAudio();
    }
  }

  void onSentenceStart() {
    print('📝 Sentence start - preparing for audio');
    // Don't clear buffer here - audio might already be arriving
  }

  void onSentenceEnd() {
    print('✅ Sentence end - playing remaining audio');
    // Play any remaining buffered audio
    if (_buffer.isNotEmpty && !_isPlaying) {
      _playBufferedAudio();
    }
  }

  Future<void> _playBufferedAudio() async {
    if (_buffer.isEmpty || _isPlaying || !_isInitialized || _isDisposing) {
      return;
    }

    _isPlaying = true;

    try {
      // Combine all buffered frames
      final totalBytes = _buffer.fold<int>(0, (sum, frame) => sum + frame.length);
      final combinedPcm = Uint8List(totalBytes);
      int offset = 0;
      for (final frame in _buffer) {
        combinedPcm.setRange(offset, offset + frame.length, frame);
        offset += frame.length;
      }
      _buffer.clear();

      print('🔊 Playing ${(totalBytes / 1024).toStringAsFixed(1)} KB of audio');

      // Add WAV header
      final wavData = _addWavHeader(combinedPcm);

      // Write to temp file
      _fileCounter++;
      final file = File('${_tempDir!.path}/tts_audio_$_fileCounter.wav');
      await file.writeAsBytes(wavData);

      // Play the file
      await _player.play(DeviceFileSource(file.path));

      print('▶️ Audio playback started');

    } catch (e) {
      print('❌ Playback error: $e');
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

  void clear() {
    _buffer.clear();
    _frameCount = 0;
  }

  Future<void> stop() async {
    _isPlaying = false;
    _buffer.clear();
    _frameCount = 0;
    _playbackTimer?.cancel();

    try {
      await _player.stop();
    } catch (e) {
      print('⚠️ Stop error: $e');
    }
  }

  Future<void> dispose() async {
    print('🧹 Disposing TTS Player...');
    _isDisposing = true;
    _isInitialized = false;
    _isPlaying = false;
    _buffer.clear();
    _frameCount = 0;
    _playbackTimer?.cancel();

    await Future.delayed(Duration(milliseconds: 100));

    try {
      await _player.stop();
      await _player.dispose();
      print('✅ TTS Player disposed');
    } catch (e) {
      print('⚠️ Dispose error (ignored): $e');
    }
  }
}

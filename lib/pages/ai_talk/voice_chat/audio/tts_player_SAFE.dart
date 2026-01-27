import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

/// TTS Player for real-time audio frame playback
/// Uses audioplayers with WAV conversion (safer than flutter_sound streaming)
/// Note: Audio session is configured globally in AudioSessionConfigHelper
class TtsPlayer {
  final AudioPlayer _player = AudioPlayer();
  final List<Uint8List> _buffer = [];
  bool _isInitialized = false;
  bool _isPlaying = false;
  Directory? _tempDir;

  final int sampleRate;
  final int numChannels;

  TtsPlayer({this.sampleRate = 24000, this.numChannels = 1});

  /// Initialize the audio player
  /// Note: Does NOT configure audio session - that's done globally
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      print('🎵 Initializing TTS Player...');
      
      // Get temp directory for audio files
      _tempDir = await getTemporaryDirectory();
      
      // Configure player
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);
      
      _isInitialized = true;
      print('✅ TTS Player initialized with audioplayers (${sampleRate}Hz)');
      print('   ✅ WAV file-based playback (stable, no native crashes)');
      print('   ✅ Low-latency mode');
    } catch (e) {
      print('❌ TTS Player init failed: $e');
      rethrow;
    }
  }

  /// Add a PCM16 frame to the buffer
  void addFrame(Uint8List pcmFrame) {
    if (_isInitialized) {
      _buffer.add(pcmFrame);
      
      // Log every 10 frames
      if (_buffer.length % 10 == 0) {
        print('🔊 Buffering frame... total: ${_buffer.length} frames');
      }
      
      // Auto-play when we have enough audio (60-100ms worth)
      if (_buffer.length >= 3 && !_isPlaying) {
        _playBufferedAudio();
      }
    }
  }

  /// Play buffered audio
  Future<void> _playBufferedAudio() async {
    if (_buffer.isEmpty || _isPlaying || !_isInitialized) return;
    
    _isPlaying = true;
    try {
      // Combine all buffered frames
      final combinedData = <int>[];
      for (final frame in _buffer) {
        combinedData.addAll(frame);
      }
      _buffer.clear();

      // Convert PCM to WAV
      final wavData = _addWavHeader(
        Uint8List.fromList(combinedData),
        sampleRate,
        numChannels,
        16,
      );
      
      // Write to temp file
      final tempFile = File('${_tempDir!.path}/tts_${DateTime.now().millisecondsSinceEpoch}.wav');
      await tempFile.writeAsBytes(wavData);
      
      print('🔊 Playing audio: ${wavData.length} bytes');
      
      // Play the audio
      await _player.play(DeviceFileSource(tempFile.path));
      
      // Wait for playback to complete
      await _player.onPlayerComplete.first.timeout(
        Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ Playback timeout, continuing...');
        },
      );
      
      _isPlaying = false;
      
      // Clean up
      try {
        await tempFile.delete();
      } catch (e) {
        print('⚠️ Failed to delete temp file: $e');
      }
      
      // Check if more audio arrived while playing
      if (_buffer.isNotEmpty && _isInitialized) {
        _playBufferedAudio();
      }
    } catch (e) {
      print('❌ Playback error: $e');
      _isPlaying = false;
    }
  }

  /// Add WAV header to PCM data
  Uint8List _addWavHeader(
    Uint8List pcmData,
    int sampleRate,
    int numChannels,
    int bitsPerSample,
  ) {
    final int byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final int blockAlign = numChannels * (bitsPerSample ~/ 8);
    final int dataSize = pcmData.length;
    final int fileSize = 36 + dataSize;

    final header = ByteData(44);
    
    // RIFF header
    header.setUint8(0, 0x52); // 'R'
    header.setUint8(1, 0x49); // 'I'
    header.setUint8(2, 0x46); // 'F'
    header.setUint8(3, 0x46); // 'F'
    header.setUint32(4, fileSize, Endian.little);
    
    // WAVE header
    header.setUint8(8, 0x57);  // 'W'
    header.setUint8(9, 0x41);  // 'A'
    header.setUint8(10, 0x56); // 'V'
    header.setUint8(11, 0x45); // 'E'
    
    // fmt subchunk
    header.setUint8(12, 0x66); // 'f'
    header.setUint8(13, 0x6D); // 'm'
    header.setUint8(14, 0x74); // 't'
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    
    // data subchunk
    header.setUint8(36, 0x64); // 'd'
    header.setUint8(37, 0x61); // 'a'
    header.setUint8(38, 0x74); // 't'
    header.setUint8(39, 0x61); // 'a'
    header.setUint32(40, dataSize, Endian.little);

    return Uint8List.fromList([...header.buffer.asUint8List(), ...pcmData]);
  }

  /// Clear any buffered audio
  void clear() {
    _buffer.clear();
    print('🧹 Audio buffer cleared');
  }

  /// Sentence start marker
  void onSentenceStart() {
    print('📝 Sentence start');
  }

  /// Sentence end marker
  void onSentenceEnd() {
    print('✅ Sentence end');
  }

  /// Stop playback immediately
  Future<void> stop() async {
    try {
      _isPlaying = false;
      await _player.stop();
      _buffer.clear();
      print('🛑 Playback stopped');
    } catch (e) {
      print('❌ Stop error: $e');
    }
  }

  /// Dispose player
  Future<void> dispose() async {
    try {
      _isInitialized = false;
      _isPlaying = false;
      
      await stop();
      await _player.dispose();
      
      print('🧹 TTS Player disposed');
    } catch (e) {
      print('❌ Dispose error: $e');
    }
  }
}

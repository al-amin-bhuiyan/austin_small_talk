// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:audioplayers/audioplayers.dart';
//
// class RingAudioPlayer {
//   final AudioPlayer _player = AudioPlayer();
//
//   // Ring buffer settings
//   static const int bufferSize = 10240; // ~426ms at 24kHz (increased for smoother playback)
//   late Uint8List _ringBuffer;
//   int _writePos = 0;
//   int _readPos = 0;
//   bool _isPlaying = false;
//   bool _streamingActive = false;
//
//   int _sampleRate;
//   int _channels;
//   Directory? _tempDir;
//
//   // Playback control
//   final int _chunkSize = 3840; // 3 frames combined (~60ms of audio)
//   int _segmentCounter = 0;
//
//   RingAudioPlayer({
//     int sampleRate = 24000,
//     int channels = 1,
//   })  : _sampleRate = sampleRate,
//         _channels = channels {
//     init();
//   }
//
//   /// Initialize ring buffer
//   void init() {
//     _ringBuffer = Uint8List(bufferSize);
//     _writePos = 0;
//     _readPos = 0;
//     _isPlaying = false;
//     _streamingActive = false;
//     print('🔄 Ring buffer initialized (${bufferSize} bytes)');
//   }
//
//   Future<void> _initTempDir() async {
//     _tempDir ??= await getTemporaryDirectory();
//   }
//
//   /// Add frame to ring buffer (circular write)
//   Future<void> addAndPlayChunk(Uint8List frame) async {
//     if (frame.isEmpty) return;
//
//     // ✅ Circular write to buffer
//     for (int i = 0; i < frame.length; i++) {
//       _ringBuffer[_writePos] = frame[i];
//       _writePos = (_writePos + 1) % bufferSize;
//     }
//
//     // Start streaming if not already playing
//     if (!_streamingActive) {
//       _streamingActive = true;
//       print('▶️ Ring buffer streaming started');
//       _streamAudio();
//     }
//   }
//
//   /// Get available data in buffer
//   int get _availableData {
//     if (_writePos >= _readPos) {
//       return _writePos - _readPos;
//     } else {
//       return bufferSize - _readPos + _writePos;
//     }
//   }
//
//   /// Stream audio from ring buffer
//   Future<void> _streamAudio() async {
//     await _initTempDir();
//
//     while (_streamingActive) {
//       final available = _availableData;
//
//       // Wait for enough data before playing
//       if (available >= _chunkSize) {
//         try {
//           // Extract chunk from ring buffer
//           final chunk = _extractChunk(_chunkSize);
//
//           if (chunk.isNotEmpty) {
//             await _playChunk(chunk);
//           }
//
//         } catch (e) {
//           print('❌ Streaming error: $e');
//           await Future.delayed(Duration(milliseconds: 50));
//         }
//       } else {
//         // Not enough data, wait a bit
//         await Future.delayed(Duration(milliseconds: 20));
//       }
//     }
//
//     print('✅ Ring buffer streaming stopped');
//   }
//
//   /// Extract chunk from ring buffer (handles wrap-around)
//   Uint8List _extractChunk(int length) {
//     final chunk = Uint8List(length);
//
//     for (int i = 0; i < length; i++) {
//       if (_availableData == 0) break; // No more data
//
//       chunk[i] = _ringBuffer[_readPos];
//       _readPos = (_readPos + 1) % bufferSize;
//     }
//
//     return chunk;
//   }
//
//   /// Play a chunk of audio
//   Future<void> _playChunk(Uint8List chunk) async {
//     if (_isPlaying) {
//       // Wait for previous chunk to finish
//       await Future.delayed(Duration(milliseconds: 10));
//     }
//
//     _isPlaying = true;
//
//     try {
//       // Convert to WAV
//       final wavData = _addWavHeader(chunk, _sampleRate, _channels, 16);
//
//       // Save to temp file
//       final file = File('${_tempDir!.path}/ring_${_segmentCounter++}.wav');
//       await file.writeAsBytes(wavData);
//
//       print('🎵 Playing chunk (${chunk.length}B) | Buffer: ${_availableData}B available');
//
//       // Play
//       await _player.play(DeviceFileSource(file.path));
//
//       // Wait for completion
//       await _player.onPlayerComplete.first;
//
//       _isPlaying = false;
//
//       // Cleanup
//       try {
//         await file.delete();
//       } catch (e) {}
//
//     } catch (e) {
//       print('❌ Chunk playback error: $e');
//       _isPlaying = false;
//     }
//   }
//
//   /// Stop streaming
//   void stop() {
//     _streamingActive = false;
//     _isPlaying = false;
//     _player.stop();
//   }
//
//   /// Clear buffer for new session
//   void clear() {
//     _writePos = 0;
//     _readPos = 0;
//     _streamingActive = false;
//     _isPlaying = false;
//     _segmentCounter = 0;
//     print('🧹 Ring buffer cleared');
//   }
//
//   /// Check if has data or is playing
//   bool get hasFrames => _availableData > 0 || _isPlaying || _streamingActive;
//
//   /// Add WAV header
//   Uint8List _addWavHeader(
//       Uint8List pcmData,
//       int sampleRate,
//       int channels,
//       int bitsPerSample,
//       ) {
//     final byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
//     final blockAlign = channels * (bitsPerSample ~/ 8);
//     final header = ByteData(44);
//
//     // RIFF
//     header.setUint8(0, 0x52); header.setUint8(1, 0x49);
//     header.setUint8(2, 0x46); header.setUint8(3, 0x46);
//     header.setUint32(4, 36 + pcmData.length, Endian.little);
//     header.setUint8(8, 0x57); header.setUint8(9, 0x41);
//     header.setUint8(10, 0x56); header.setUint8(11, 0x45);
//
//     // fmt
//     header.setUint8(12, 0x66); header.setUint8(13, 0x6D);
//     header.setUint8(14, 0x74); header.setUint8(15, 0x20);
//     header.setUint32(16, 16, Endian.little);
//     header.setUint16(20, 1, Endian.little);
//     header.setUint16(22, channels, Endian.little);
//     header.setUint32(24, sampleRate, Endian.little);
//     header.setUint32(28, byteRate, Endian.little);
//     header.setUint16(32, blockAlign, Endian.little);
//     header.setUint16(34, bitsPerSample, Endian.little);
//
//     // data
//     header.setUint8(36, 0x64); header.setUint8(37, 0x61);
//     header.setUint8(38, 0x74); header.setUint8(39, 0x61);
//     header.setUint32(40, pcmData.length, Endian.little);
//
//     final wav = Uint8List(44 + pcmData.length);
//     wav.setRange(0, 44, header.buffer.asUint8List());
//     wav.setRange(44, 44 + pcmData.length, pcmData);
//
//     return wav;
//   }
//
//   Future<void> dispose() async {
//     stop();
//     await _player.dispose();
//   }
// }
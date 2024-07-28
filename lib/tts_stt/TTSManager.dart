import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

// Initialize logger
var logger = Logger();

class TTSManager {
  final FlutterTts _flutterTts = FlutterTts();

  TTSManager() {
    _initializeTts();
  }

  // Initialize TTS with default settings
  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      logger.e("Error initializing TTS: $e");
    }
  }

  // Function to speak the given text
  Future<void> speakText(String text, {Function? onComplete}) async {
    logger.i("Speaking: $text");
    try {
      await _flutterTts.speak(text);
      if (onComplete != null) {
        _flutterTts.setCompletionHandler(() {
          logger.i("Finished speaking: $text");
          onComplete();
        });
      }
    } catch (e) {
      logger.e("Error speaking text: $e");
    }
  }

  // Function to stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      logger.e("Error stopping TTS: $e");
    }
  }
}

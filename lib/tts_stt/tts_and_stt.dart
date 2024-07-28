import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';

// Initialize logger
var logger = Logger();

class VoiceInteraction {
  final FlutterTts _flutterTts = FlutterTts(); // Text-to-Speech instance
  final stt.SpeechToText _speechToText = stt.SpeechToText(); // Speech-to-Text instance
  bool _isListening = false; // Flag to check if currently listening
  bool _isProcessing = false; // Flag to check if currently processing
  bool _isInitialized = false; // Flag to check if initialized

  // Constructor to initialize TTS
  VoiceInteraction() {
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

  // Sanitize text to remove special characters
  String sanitizeText(String text) {
    return text.replaceAll('*', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('_', '')
        .replaceAll('~', '')
        .replaceAll('`', '');
  }

  // Function to speak the given text
  Future<void> speakText(String text, {Function? onComplete}) async {
    String sanitizedText = sanitizeText(text);
    logger.i("Speaking: $sanitizedText");
    try {
      await _flutterTts.speak(sanitizedText);
      if (onComplete != null) {
        _flutterTts.setCompletionHandler(() {
          logger.i("Finished speaking: $sanitizedText");
          _isProcessing = false;
          onComplete();
        });
      } else {
        _isProcessing = false;
      }
    } catch (e) {
      logger.e("Error speaking text: $e");
    }
  }

  // Function to start listening for speech
  Future<void> startListening(Function(String) onDescribeCommand) async {
    if (_isListening || _isProcessing) {
      return;
    }

    if (!_isInitialized) {
      try {
        bool available = await _speechToText.initialize(
          onStatus: (status) {
            logger.w("Speech status: $status");
            if (status == 'done' || status == 'notListening') {
              _isListening = false;
              _isProcessing = false;
            }
          },
          onError: (error) {
            logger.e("Speech error: ${error.errorMsg}");
            _isListening = false;
            _isProcessing = false;
          },
        );

        if (!available) {
          logger.e("Speech recognition not available");
          return;
        }

        _isInitialized = true;
      } catch (e) {
        logger.e("Error initializing speech recognition: $e");
        return;
      }
    }

    _isListening = true;
    _isProcessing = false;
    logger.i("Listening started...");
    _listen(onDescribeCommand);
  }

  // Function to handle listening logic
  void _listen(Function(String) onDescribeCommand) {
    // Create SpeechListenOptions
    stt.SpeechListenOptions options = stt.SpeechListenOptions(
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
      // Other options can be added here
    );

    try {
      // Start listening with the created options
      _speechToText.listen(
        onResult: (val) {
          logger.w("Speech result: ${val.recognizedWords}");
          if (val.finalResult) {
            String command = val.recognizedWords.toLowerCase();
            if (!_isProcessing) {
              _isProcessing = true;
              _isListening = false;
              logger.i("Final speech result: $command");
              onDescribeCommand(command);
            }
          }
        },
        listenOptions: options,
      );
    } catch (e) {
      logger.e("Error during speech listening: $e");
      _isListening = false;
      _isProcessing = false;
    }
  }

  // Function to stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      if (_isListening) {
        await _speechToText.stop();
        _isListening = false;
      }
      _isProcessing = false;
    } catch (e) {
      logger.e("Error stopping TTS or speech recognition: $e");
    }
  }

  // Function to dispose resources
  void dispose() {
    _flutterTts.stop();
    stopSpeaking();
  }
}

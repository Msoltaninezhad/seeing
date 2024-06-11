import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void printRed(String message) {
  print('\x1B[31m$message\x1B[0m');
}

void printGreen(String message) {
  print('\x1B[32m$message\x1B[0m');
}

void printYellow(String message) {
  print('\x1B[33m$message\x1B[0m');
}

void printBlue(String message) {
  print('\x1B[34m$message\x1B[0m');
}

class VoiceInteraction {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isInitialized = false; // New flag to check initialization

  VoiceInteraction() {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  String sanitizeText(String text) {
    return text.replaceAll('*', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('_', '')
        .replaceAll('~', '')
        .replaceAll('`', '');
  }

  Future<void> speakText(String text, {Function? onComplete}) async {
    String sanitizedText = sanitizeText(text);
    printBlue("Speaking: $sanitizedText");
    await _flutterTts.speak(sanitizedText);
    if (onComplete != null) {
      _flutterTts.setCompletionHandler(() {
        printGreen("Finished speaking: $sanitizedText");
        _isProcessing = false; // Reset _isProcessing flag
        onComplete();
      });
    } else {
      _isProcessing = false; // Reset _isProcessing flag if no completion handler
    }
  }

  Future<void> startListening(Function(String) onDescribeCommand) async {
    if (_isListening || _isProcessing) {
      return;
    }

    if (!_isInitialized) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          printYellow("Speech status: $status");
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            _isProcessing = false; // Ensure _isProcessing is reset
          }
        },
        onError: (error) {
          printRed("Speech error: ${error.errorMsg}");
          _isListening = false;
          _isProcessing = false; // Ensure _isProcessing is reset
        },
      );

      if (!available) {
        printRed("Speech recognition not available");
        return;
      }

      _isInitialized = true; // Set initialization flag
    }

    _isListening = true;
    _isProcessing = false; // Ensure _isProcessing is reset
    printBlue("Listening started...");
    _listen(onDescribeCommand);
  }

  void _listen(Function(String) onDescribeCommand) {
    _speechToText.listen(
      onResult: (val) {
        printYellow("Speech result: ${val.recognizedWords}");
        if (val.finalResult) {
          String command = val.recognizedWords.toLowerCase();
          if (!_isProcessing) {
            _isProcessing = true;
            _isListening = false;
            printGreen("Final speech result: $command");
            onDescribeCommand(command);
          }
        }
      },
      listenFor: Duration(seconds: 120),
      pauseFor: Duration(seconds: 10),
      partialResults: true,
      localeId: 'en_US',
      onSoundLevelChange: (level) {},
      cancelOnError: true,
    );
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
    _isProcessing = false;
  }

  void dispose() {
    _flutterTts.stop();
    stopSpeaking();
  }
}

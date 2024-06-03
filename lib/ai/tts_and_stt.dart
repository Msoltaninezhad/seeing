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

  VoiceInteraction() {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    printGreen('Initializing TTS');
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    printGreen('TTS Initialized');
  }

  Future<void> speakText(String text) async {
    printBlue('Speaking text: $text');
    await _flutterTts.speak(text);
  }

  Future<void> startListening(Function(String) onResult) async {
    if (_isListening) {
      printRed('Already listening, stopping current instance');
      await _speechToText.stop();
      _isListening = false;
    }

    printGreen('Initializing Speech to Text');
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        printYellow('onStatus: $status');
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          printYellow('Status: $status, Restarting listening');
          startListening(onResult); // Restart listening
        }
      },
      onError: (error) {
        printRed('onError: $error');
        if (error.errorMsg == 'error_busy') {
          printRed('Speech recognition service is busy. Retrying...');
          Future.delayed(Duration(seconds: 1), () {
            startListening(onResult);
          });
        } else {
          _isListening = false;
          startListening(onResult); // Restart listening on error
        }
      },
    );

    if (available) {
      printGreen('Speech recognition available, starting to listen');
      _isListening = true;
      _listen(onResult);
    } else {
      printRed('Speech recognition not available');
    }
  }

  void _listen(Function(String) onResult) {
    printYellow('Listening...');
    _speechToText.listen(
      onResult: (val) {
        printBlue('Recognized words: ${val.recognizedWords}');
        onResult(val.recognizedWords);
        if (val.finalResult) {
          printYellow('Final result received');
          _isListening = false;
        }
      },
      listenFor: Duration(seconds: 30), // Adjust duration as needed
      pauseFor: Duration(seconds: 5), // Adjust pause duration as needed
      partialResults: true,
      localeId: 'en_US',
      onSoundLevelChange: (level) => printYellow('Sound level: $level'),
      cancelOnError: true,
    );
  }

  void stopListening() async {
    if (_isListening) {
      printRed('Stopping listening');
      await _speechToText.stop();
      _isListening = false;
    }
  }

  void dispose() {
    printRed('Disposing TTS and Speech to Text');
    _flutterTts.stop();
    stopListening();
  }
}

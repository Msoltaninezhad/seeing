// Import the necessary packages for text-to-speech and speech-to-text functionalities
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Functions to print colored messages in the console for debugging purposes
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

// VoiceInteraction class handles the text-to-speech and speech-to-text interactions
class VoiceInteraction {
  final FlutterTts _flutterTts = FlutterTts(); // Instance of FlutterTts for text-to-speech
  final stt.SpeechToText _speechToText = stt.SpeechToText(); // Instance of SpeechToText for speech-to-text
  bool _isListening = false; // Indicates if the system is currently listening
  bool _isProcessing = false; // Indicates if a command is being processed

  // Constructor to initialize TTS settings
  VoiceInteraction() {
    _initializeTts();
  }

  // Initialize the TTS settings
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US"); // Set language to English (US)
    await _flutterTts.setSpeechRate(0.5); // Set speech rate
    await _flutterTts.setVolume(1.0); // Set volume
    await _flutterTts.setPitch(1.0); // Set pitch
  }

  // Function to speak the provided text using TTS
  Future<void> speakText(String text) async {
    await _flutterTts.speak(text);
  }

  // Function to start listening for voice commands
  Future<void> startListening(Function(String) onDescribeCommand) async {
    if (_isListening) {
      await _speechToText.stop(); // Stop listening if already listening
      _isListening = false;
    }

    // Initialize the speech-to-text functionality
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          if (!_isProcessing) {
            startListening(onDescribeCommand); // Restart listening if not processing
          }
        }
      },
      onError: (error) {
        if (error.errorMsg == 'error_busy') {
          Future.delayed(Duration(seconds: 1), () {
            if (!_isProcessing) {
              startListening(onDescribeCommand); // Retry listening if an error occurs
            }
          });
        } else {
          _isListening = false;
          if (!_isProcessing) {
            startListening(onDescribeCommand); // Restart listening if not processing
          }
        }
      },
    );

    if (available) {
      _isListening = true;
      _listen(onDescribeCommand); // Start listening if initialization is successful
    }
  }

  // Function to handle the actual listening process
  void _listen(Function(String) onDescribeCommand) {
    _speechToText.listen(
      onResult: (val) {
        if (val.finalResult) {
          String command = val.recognizedWords.toLowerCase();
          if (command == "describe" && !_isProcessing) {
            _isProcessing = true;
            _isListening = false;
            onDescribeCommand(command); // Call the provided command callback
          }
        }
      },
      listenFor: Duration(seconds: 30), // Maximum listening duration
      pauseFor: Duration(seconds: 5), // Pause duration between listens
      partialResults: true, // Allow partial results
      localeId: 'en_US', // Locale for speech recognition
      onSoundLevelChange: (level) {}, // Sound level change callback (not used)
      cancelOnError: true, // Cancel on error
    );
  }

  // Function to stop listening
  void stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  // Function to dispose resources
  void dispose() {
    _flutterTts.stop(); // Stop TTS
    stopListening(); // Stop listening
  }
}

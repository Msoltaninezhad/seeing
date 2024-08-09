import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';

class VoiceInteractionService {
  final VoiceInteraction _voiceInteraction = VoiceInteraction();
  final Logger logger = Logger();
  bool _isListening = false;

  Future<void> speakText(String text, {void Function()? onComplete}) async {
    try {
      await _voiceInteraction.speakText(text, onComplete: () {
        logger.i('Finished speaking: $text');
        if (onComplete != null) {
          onComplete();
        }
      });
      logger.i('Text spoken: $text');
    } catch (error) {
      logger.e('Error speaking text: $error');
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _voiceInteraction.stopSpeaking();
      if (_isListening) {
        await _voiceInteraction.stopListening();
        _isListening = false;
      }
      logger.i('Stopped speaking and reset states.');
    } catch (error) {
      logger.e('Error stopping speech: $error');
      _isListening = false;
    }
  }

  void startListening(Function(String) onCommand) async {
    try {
      _isListening = true;
      await _voiceInteraction.startListening(onCommand);
      logger.i('Started listening for voice commands.');
    } catch (error) {
      _isListening = false;
      logger.e('Error starting to listen: $error');
    }
  }

  void dispose() {
    _voiceInteraction.dispose();
    logger.i('Disposed voice interaction.');
  }
}

class VoiceInteraction {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  Future<void> speakText(String text, {void Function()? onComplete}) async {
    await _flutterTts.speak(text);
    if (onComplete != null) {
      _flutterTts.setCompletionHandler(onComplete);
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  Future<void> startListening(Function(String) onCommand) async {
    bool available = await _speechToText.initialize();
    if (available) {
      _speechToText.listen(onResult: (result) {
        if (result.finalResult) {
          onCommand(result.recognizedWords);
        }
      });
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
  }
}

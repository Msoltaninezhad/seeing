import 'package:HearTheVisionG/tts_stt/tts_and_stt.dart';
import 'package:logger/logger.dart';

/// Service for handling voice interactions, including text-to-speech and speech-to-text.
class VoiceInteractionService {
  final VoiceInteraction _voiceInteraction = VoiceInteraction();  // Instance of the VoiceInteraction class
  final Logger logger = Logger();  // Logger instance for logging messages

  /// Speaks the given text using the text-to-speech service.
  ///
  /// An optional [onComplete] callback can be provided to execute after speaking is complete.
  Future<void> speakText(String text, {Function? onComplete}) async {
    try {
      await _voiceInteraction.speakText(text, onComplete: onComplete);
      logger.i('Text spoken: $text');
    } catch (error) {
      logger.e('Error speaking text: $error');
    }
  }

  /// Starts listening for voice commands using the speech-to-text service.
  ///
  /// The [onCommand] callback is executed with the recognized command as a parameter.
  void startListening(Function(String) onCommand) {
    try {
      _voiceInteraction.startListening(onCommand);
      logger.i('Started listening for voice commands.');
    } catch (error) {
      logger.e('Error starting to listen: $error');
    }
  }

  /// Stops any ongoing text-to-speech activity.
  Future<void> stopSpeaking() async {
    try {
      await _voiceInteraction.stopSpeaking();
      logger.i('Stopped speaking.');
    } catch (error) {
      logger.e('Error stopping speech: $error');
    }
  }

  /// Disposes the voice interaction instance to free up resources.
  void dispose() {
    _voiceInteraction.dispose();
    logger.i('Disposed voice interaction.');
  }
}

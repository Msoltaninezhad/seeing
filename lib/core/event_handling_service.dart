import 'dart:async';
import 'package:logger/logger.dart';
import 'package:HearTheVisionG/ai/gemini_service.dart';
import 'package:HearTheVisionG/core/voice_interaction_service.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:HearTheVisionG/ai/feedback.dart';  // Import the FeedbackService

/// Service to handle user interactions such as taps and long presses.
class EventHandlingService {
  final VoiceInteractionService _voiceService;
  final GeminiService _geminiService;
  final FeedbackService _feedbackService = FeedbackService();  // Initialize FeedbackService
  final Logger _logger = Logger();
  Timer? _longPressTimer;

  static const String esp32ButtonUrl = 'http://esp32_button_ip'; // Replace with your ESP32 button IP address

  EventHandlingService(this._voiceService, this._geminiService);

  /// Fetches a signal from the physical button over Wi-Fi.
  Future<bool> _fetchSignalFromButton() async {
    try {
      final response = await http.get(Uri.parse('$esp32ButtonUrl/signal'));
      if (response.statusCode == 200 && response.body == '1') { // Assuming '1' indicates the button was pressed
        _logger.i('Signal received from physical button.');
        return true;
      } else {
        _logger.e('Failed to receive signal from physical button. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('Error receiving signal from physical button: $e');
      return false;
    }
  }

  /// Handles tap events by either stopping the current interaction or starting a new capture and describe process.
  Future<void> handleTap({
    required bool isDescribing,
    required bool isAskingQuestion,
    required Future<void> Function() captureAndDescribe,
    required Future<void> Function() stopInteraction,
  }) async {
    final bool buttonSignal = await _fetchSignalFromButton();

    if (buttonSignal) {
      // Handle the action triggered by the physical button
      await _handleTapOrButtonPress(isDescribing, isAskingQuestion, captureAndDescribe, stopInteraction);
    } else {
      // Fallback to handling screen tap
      await _handleTapOrButtonPress(isDescribing, isAskingQuestion, captureAndDescribe, stopInteraction);
    }
  }

  Future<void> _handleTapOrButtonPress(
      bool isDescribing,
      bool isAskingQuestion,
      Future<void> Function() captureAndDescribe,
      Future<void> Function() stopInteraction) async {
    if (isDescribing || isAskingQuestion) {
      await stopInteraction();
    } else {
      await _voiceService.stopSpeaking(); // Ensure any ongoing speech is stopped before starting a new one
      await _voiceService.speakText("Image description");
      await captureAndDescribe();
    }
  }

  /// Handles the start of a long press event by initiating a timer.
  void handleLongPressStart({
    required bool isAskingQuestion,
    required String descriptionText,
    required String? imagePath,
    required Future<void> Function() descriptionComplete,
    required Future<void> Function() setIsAskingQuestionTrue,
    required Future<void> Function() setIsAskingQuestionFalse,
  }) {
    _longPressTimer = Timer(const Duration(seconds: 2), () async {
      if (!isAskingQuestion) {
        await _voiceService.speakText("Ask question");
        _voiceService.startListening((command) async {
          _logger.i("User said: $command");

          if (command.toLowerCase().contains("feedback")) {
            await _feedbackService.sendFeedback(command);
          } else {
            await setIsAskingQuestionTrue();
            final response = await _geminiService.handleQuestionWithImage(descriptionText, command, imagePath!);
            await _voiceService.speakText(response, onComplete: descriptionComplete);
            await setIsAskingQuestionFalse(); // Reset the state after interaction
          }
        });
      }
    });
  }

  /// Handles the end of a long press event by canceling the timer if it is active.
  void handleLongPressEnd(LongPressEndDetails details) {
    if (_longPressTimer != null && _longPressTimer!.isActive) {
      _longPressTimer!.cancel();
    }
  }

  /// Disposes of the long press timer.
  void dispose() {
    _longPressTimer?.cancel();
  }
}

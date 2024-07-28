import 'dart:async';
import 'package:logger/logger.dart';
import 'package:HearTheVisionG/ai/gemini_service.dart';
import 'package:HearTheVisionG/core/voice_interaction_service.dart';
import 'package:flutter/gestures.dart';

/// Service to handle user interactions such as taps and long presses.
class EventHandlingService {
  final VoiceInteractionService _voiceService;
  final GeminiService _geminiService;
  final Logger _logger = Logger();
  Timer? _longPressTimer;

  EventHandlingService(this._voiceService, this._geminiService);

  /// Handles tap events by either stopping the current interaction or starting a new capture and describe process.
  void handleTap({
    required bool isDescribing,
    required bool isAskingQuestion,
    required Future<void> Function() captureAndDescribe,
    required Future<void> Function() stopInteraction,
  }) {
    if (isDescribing || isAskingQuestion) {
      stopInteraction();
    } else {
      captureAndDescribe();
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
          _logger.i("User asked: $command");
          await setIsAskingQuestionTrue();
          final response = await _geminiService.handleQuestionWithImage(descriptionText, command, imagePath!);
          await _voiceService.speakText(response, onComplete: descriptionComplete);
          await setIsAskingQuestionFalse(); // Reset the state after interaction
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

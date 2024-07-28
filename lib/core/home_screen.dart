import 'package:flutter/material.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:HearTheVisionG/ai/gemini_service.dart';
import 'package:HearTheVisionG/core/camera_controller_service.dart';
import 'package:HearTheVisionG/core/voice_interaction_service.dart';
import 'package:HearTheVisionG/core/image_processing_service.dart';
import 'package:HearTheVisionG/core/ui_service.dart';
import 'package:HearTheVisionG/core/event_handling_service.dart';  // Import the new service

/// The main screen of the application, responsible for handling user interactions
/// and displaying the UI elements.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final CameraControllerService _cameraService = CameraControllerService();  // Service for camera operations
  final VoiceInteractionService _voiceService = VoiceInteractionService();  // Service for voice interactions
  final ImageProcessingService _imageService = ImageProcessingService();  // Service for image processing
  final UIService _uiService = UIService();  // Service for UI components
  final GeminiService _geminiService = GeminiService();  // Service for AI interactions
  late final EventHandlingService _eventHandlingService;  // Service for handling events
  bool _isLoading = false;  // State to indicate if an operation is in progress
  bool _isDescribing = false;  // State to indicate if an image is being described
  bool _isAskingQuestion = false;  // State to indicate if a question is being asked
  String? imagePath;  // Path to the captured image
  String descriptionText = '';  // Description of the image
  final logger = Logger();  // Logger instance for logging messages

  @override
  void initState() {
    super.initState();
    _eventHandlingService = EventHandlingService(_voiceService, _geminiService);  // Initialize the event handling service
    _cameraService.initializeCamera().then((_) {
      setState(() {});
    });
  }

  /// Captures an image and generates its description using the AI service.
  Future<void> _captureAndDescribe() async {
    setState(() {
      _isLoading = true;
      _isDescribing = true;
    });

    try {
      if (_cameraService.cameraController != null && _cameraService.cameraController!.value.isInitialized) {
        imagePath = await _imageService.captureAndSaveImage(_cameraService.cameraController!);

        if (imagePath != null) {
          final response = await _geminiService.generateDescription(imagePath!);
          logger.i('Description response: $response');

          setState(() {
            descriptionText = response;
          });

          await _voiceService.speakText(response, onComplete: _descriptionComplete);
        } else {
          logger.e('Failed to capture or save image');
        }
      } else {
        logger.e('Camera not initialized or not available');
      }
    } catch (error) {
      logger.e('Error during capture and describe: $error');
      await _voiceService.speakText('Failed to communicate with Gemini API.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Callback when the description process is complete.
  Future<void> _descriptionComplete() async {
    setState(() {
      _isDescribing = false;
    });
  }

  /// Stops any ongoing interaction.
  Future<void> _stopInteraction() async {
    await _voiceService.stopSpeaking();
    setState(() {
      _isDescribing = false;
      _isLoading = false;
      _isAskingQuestion = false;
    });
  }

  /// Sets the state to indicate that a question is being asked.
  Future<void> _setIsAskingQuestionTrue() async {
    setState(() {
      _isAskingQuestion = true;
    });
  }

  /// Resets the state to indicate that a question is no longer being asked.
  Future<void> _setIsAskingQuestionFalse() async {
    setState(() {
      _isAskingQuestion = false;
    });
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _voiceService.dispose();
    _eventHandlingService.dispose();  // Dispose the service
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final textSize = topPadding * 0.7;
    final logoSize = topPadding * 1;

    return Scaffold(
      appBar: _uiService.buildAppBar(topPadding, logoSize, textSize),
      body: _uiService.buildBody(
        cameraController: _cameraService.cameraController,
        isLoading: _isLoading,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        onTap: () => _eventHandlingService.handleTap(
          isDescribing: _isDescribing,
          isAskingQuestion: _isAskingQuestion,
          captureAndDescribe: _captureAndDescribe,
          stopInteraction: _stopInteraction,
        ),
        onLongPressStart: (details) => _eventHandlingService.handleLongPressStart(
          isAskingQuestion: _isAskingQuestion,
          descriptionText: descriptionText,
          imagePath: imagePath,
          descriptionComplete: _descriptionComplete,
          setIsAskingQuestionTrue: _setIsAskingQuestionTrue,
          setIsAskingQuestionFalse: _setIsAskingQuestionFalse,
        ),
        onLongPressEnd: (details) => _eventHandlingService.handleLongPressEnd(details),
      ),
    );
  }
}

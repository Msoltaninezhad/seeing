import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:convert';
import 'package:visually_impaired_app/ai/object_detection.dart';
import 'package:visually_impaired_app/ai/chatgpt_service.dart';
import 'package:visually_impaired_app/ai/tts_and_stt.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _cameraController;
  ObjectDetection? _objectDetection;
  ChatGPTService _chatGPTService = ChatGPTService();
  VoiceInteraction _voiceInteraction = VoiceInteraction();
  String _detectedObjects = '';
  String _generatedDescription = '';
  String descriptionText = '';  // Variable to save description text
  String questionText = '';     // Variable to save question text
  bool _isLoading = false;
  String _speechText = '';
  Timer? _longPressTimer;
  bool _isAskingQuestion = false;
  bool _isDescribing = false; // New state variable to track if describing

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeObjectDetection();
  }

  Future<void> _initializeObjectDetection() async {
    _objectDetection = await ObjectDetection.create();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController?.initialize();
    setState(() {});
  }

  Future<void> _captureAndDescribe() async {
    setState(() {
      _isLoading = true;
      _isDescribing = true; // Start describing
    });

    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile picture = await _cameraController!.takePicture();
        final bytes = await picture.readAsBytes();
        final imageBase64 = base64Encode(bytes);

        final response = await _chatGPTService.generateDescription('Describe this image.', imageBase64);
        setState(() {
          _generatedDescription = response;
          descriptionText = response;  // Save the description text
        });
        await _voiceInteraction.speakText(response, onComplete: _descriptionComplete);
      } else {
        print('Camera not initialized or not available');
      }
    } catch (error) {
      setState(() {
        _generatedDescription = 'Error: $error';
      });
      await _voiceInteraction.speakText('Failed to communicate with ChatGPT.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _descriptionComplete() {
    setState(() {
      _isAskingQuestion = false;
      _isDescribing = false; // Stop describing
    });
  }

  void _stopInteraction() async {
    await _voiceInteraction.stopSpeaking();
    setState(() {
      _isAskingQuestion = false;
      _isLoading = false;
      _isDescribing = false; // Stop describing if active
    });
  }

  void _handlePress() {
    if (_isDescribing || _isAskingQuestion) {
      _stopInteraction();
    } else {
      _captureAndDescribe();
    }
  }

  void _handleLongPressStart() {
    _longPressTimer = Timer(Duration(seconds: 2), () async {
      if (!_isAskingQuestion) {
        await _voiceInteraction.speakText("Ask question");
        _voiceInteraction.startListening((command) async {
          // Handle the command here
          print("User asked: $command");
          setState(() {
            questionText = command;  // Save the question text
          });
          // Send the image description and question text to ChatGPT
          final response = await _chatGPTService.handleQuestionWithImage(descriptionText, command);
          setState(() {
            _speechText = response;
          });
          await _voiceInteraction.speakText(response);
        });
      }
    });
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (_longPressTimer != null && _longPressTimer!.isActive) {
      _longPressTimer!.cancel();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _objectDetection?.close();
    _voiceInteraction.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Object Detection and ChatGPT Integration')),
      body: Stack(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          Center(
            child: GestureDetector(
              onTap: _handlePress,
              onLongPressStart: (details) => _handleLongPressStart(),
              onLongPressEnd: _handleLongPressEnd,
              child: OutlinedButton(
                onPressed: null,
                child: Text(
                  'Hold for Question, Tap to Describe',
                  style: TextStyle(fontSize: 24),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 320, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),
          // Commented out the text display part
          // Positioned(
          //   bottom: 20,
          //   left: 20,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text('Speech Text: $_speechText', style: TextStyle(color: Colors.white)),
          //       Text('Description: $_generatedDescription', style: TextStyle(color: Colors.white)),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

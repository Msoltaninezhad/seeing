import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:visually_impaired_app/ai/object_detection.dart';
import 'package:visually_impaired_app/ai/chatgpt_service.dart';
import 'package:visually_impaired_app/ai/tts_and_stt.dart';
import 'package:permission_handler/permission_handler.dart';


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
  bool _isLoading = false;
  String _speechText = '';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    printGreen('Requesting camera and microphone permissions');
    var cameraStatus = await Permission.camera.request();
    var microphoneStatus = await Permission.microphone.request();
    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      printGreen('Camera and microphone permissions granted');
      await _initializeCamera();
      _initializeObjectDetection();
      _startListening();
    } else {
      printRed('Camera or microphone permission denied');
    }
  }

  Future<void> _initializeCamera() async {
    printGreen('Initializing camera');
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController?.initialize();
    setState(() {});
    printGreen('Camera initialized');
  }

  Future<void> _initializeObjectDetection() async {
    printGreen('Initializing object detection');
    _objectDetection = await ObjectDetection.create();
    printGreen('Object detection initialized');
  }

  void _startListening() {
    printGreen('Starting to listen');
    _voiceInteraction.startListening((speechText) async {
      setState(() {
        _speechText = speechText;
        _isLoading = true;
      });

      try {
        String imageBase64 = "";
        if (_cameraController != null && _cameraController!.value.isInitialized) {
          final XFile picture = await _cameraController!.takePicture();
          printGreen('Image captured: ${picture.path}');

          final bytes = await picture.readAsBytes();
          imageBase64 = base64Encode(bytes);
        } else {
          printRed('Camera not initialized or not available');
        }

        printGreen('Sending speech text and image to ChatGPT');
        final response = await _chatGPTService.generateDescription(speechText, imageBase64);
        setState(() {
          _generatedDescription = response;
        });
        printGreen('ChatGPT response: $response');
        await _voiceInteraction.speakText(response);
      } catch (error) {
        setState(() {
          _generatedDescription = 'Error: $error';
        });
        printRed('Error communicating with ChatGPT: $error');
        await _voiceInteraction.speakText('Failed to communicate with ChatGPT.');
      } finally {
        setState(() {
          _isLoading = false;
        });
        // Restart listening after processing the current speech and image
        _startListening();
      }
    });
  }

  @override
  void dispose() {
    printRed('Disposing resources');
    _cameraController?.dispose();
    _objectDetection?.close();
    _voiceInteraction.dispose();
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
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Speech Text: $_speechText', style: TextStyle(color: Colors.white)),
                Text('Description: $_generatedDescription', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

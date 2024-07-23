import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:HearTheVisionG/ai/gemini_service.dart';
import 'package:HearTheVisionG/ai/tts_and_stt.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _cameraController;
  GeminiService _geminiService = GeminiService();
  VoiceInteraction _voiceInteraction = VoiceInteraction();
  bool _isLoading = false;
  bool _isDescribing = false;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController?.initialize();

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      print('Camera initialized with resolution: ${_cameraController!.value.previewSize}');
    } else {
      print('Failed to initialize the camera.');
    }

    setState(() {});
  }

  Future<void> _captureAndDescribe() async {
    setState(() {
      _isLoading = true;
      _isDescribing = true;
    });

    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile picture = await _cameraController!.takePicture();
        final directory = await getApplicationDocumentsDirectory();
        imagePath = '${directory.path}/captured_image.png';
        await picture.saveTo(imagePath!);

        print('Image captured and saved to $imagePath');
        print('Image MIME type: image/png');

        final response = await _geminiService.generateDescription(imagePath!);
        print('Description response: $response');

        await _voiceInteraction.speakText(response, onComplete: _descriptionComplete);
      } else {
        print('Camera not initialized or not available');
      }
    } catch (error) {
      print('Error during capture and describe: $error');
      await _voiceInteraction.speakText('Failed to communicate with Gemini API.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _descriptionComplete() {
    setState(() {
      _isDescribing = false;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _voiceInteraction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HearTheVision')),
      body: Stack(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          Center(
            child: GestureDetector(
              onTap: _captureAndDescribe,
              child: OutlinedButton(
                onPressed: null,
                child: Text(
                  ' Tap to Describe',
                  style: TextStyle(fontSize: 20),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 320, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: Colors.blue, width: 4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:typed_data';  // Importing for handling byte data
import 'package:flutter/material.dart';  // Importing Flutter's material design package
import 'package:camera/camera.dart';  // Importing camera package for accessing camera functionalities
import 'dart:async';  // Importing for asynchronous programming support
import 'dart:io';  // Importing for file system operations
import 'package:HearTheVisionG/ai/gemini_service.dart';  // Importing custom service for AI descriptions
import 'package:HearTheVisionG/ai/tts_and_stt.dart';  // Importing custom service for text-to-speech and speech-to-text
import 'package:path_provider/path_provider.dart';  // Importing for finding commonly used locations on the filesystem

// HomeScreen widget with stateful behavior
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// State class for HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  CameraController? _cameraController;  // Camera controller to interact with the camera
  GeminiService _geminiService = GeminiService();  // Instance of the custom AI description service
  VoiceInteraction _voiceInteraction = VoiceInteraction();  // Instance of the custom voice interaction service
  bool _isLoading = false;  // Flag to indicate if the app is loading
  bool _isDescribing = false;  // Flag to indicate if the app is describing an image
  bool _isAskingQuestion = false;  // Flag to indicate if the app is in question mode
  Timer? _longPressTimer;  // Timer for handling long press
  String? imagePath;  // Path to the captured image
  String descriptionText = '';  // Text of the image description

  @override
  void initState() {
    super.initState();
    _initializeCamera();  // Initialize camera when the state is created
  }

  // Function to initialize the camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();  // Get available cameras
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);  // Create a camera controller
    await _cameraController?.initialize();  // Initialize the controller

    // Check if the camera is initialized and log the result
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      print('Camera initialized with resolution: ${_cameraController!.value.previewSize}');
    } else {
      print('Failed to initialize the camera.');
    }

    setState(() {});  // Update the state
  }

  // Function to capture an image and generate its description
  Future<void> _captureAndDescribe() async {
    setState(() {
      _isLoading = true;  // Set loading flag to true
      _isDescribing = true;  // Set describing flag to true
    });

    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile picture = await _cameraController!.takePicture();  // Capture the picture
        final directory = await getApplicationDocumentsDirectory();  // Get the application documents directory
        imagePath = '${directory.path}/captured_image.png';  // Define the image path
        await picture.saveTo(imagePath!);  // Save the picture to the defined path

        // Log the image path and MIME type
        print('Image captured and saved to $imagePath');
        print('Image MIME type: image/png');

        final response = await _geminiService.generateDescription(imagePath!);  // Generate image description
        print('Description response: $response');

        setState(() {
          descriptionText = response;  // Set the description text
        });

        // Use text-to-speech to read out the description
        await _voiceInteraction.speakText(response, onComplete: _descriptionComplete);
      } else {
        print('Camera not initialized or not available');
      }
    } catch (error) {
      print('Error during capture and describe: $error');
      await _voiceInteraction.speakText('Failed to communicate with Gemini API.');  // Handle errors
    } finally {
      setState(() {
        _isLoading = false;  // Reset loading flag
      });
    }
  }

  // Callback function when description is complete
  void _descriptionComplete() {
    setState(() {
      _isDescribing = false;  // Reset describing flag
    });
  }

  // Function to handle tap event
  void _handleTap() {
    if (_isDescribing || _isAskingQuestion) {
      _stopInteraction();  // Stop interaction if already describing or asking question
    } else {
      _captureAndDescribe();  // Capture and describe image
    }
  }

  // Function to handle long press start event
  void _handleLongPressStart() {
    _longPressTimer = Timer(Duration(seconds: 2), () async {
      if (!_isAskingQuestion) {
        await _voiceInteraction.speakText("Ask question");  // Prompt user to ask a question
        _voiceInteraction.startListening((command) async {
          print("User asked: $command");
          setState(() {
            _isAskingQuestion = true;  // Set asking question flag
          });
          final response = await _geminiService.handleQuestionWithImage(descriptionText, command, imagePath!);
          setState(() {
            _isAskingQuestion = false;  // Reset asking question flag
          });
          await _voiceInteraction.speakText(response, onComplete: _descriptionComplete);  // Provide the response
        });
      }
    });
  }

  // Function to handle long press end event
  void _handleLongPressEnd(LongPressEndDetails details) {
    if (_longPressTimer != null && _longPressTimer!.isActive) {
      _longPressTimer!.cancel();  // Cancel the long press timer
    }
  }

  // Function to stop interaction
  void _stopInteraction() async {
    await _voiceInteraction.stopSpeaking();  // Stop text-to-speech
    setState(() {
      _isDescribing = false;  // Reset flags
      _isLoading = false;
      _isAskingQuestion = false;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();  // Dispose camera controller
    _voiceInteraction.dispose();  // Dispose voice interaction service
    _longPressTimer?.cancel();  // Cancel timer
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Get the size of the screen and the safe area insets
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final appBarHeight = kToolbarHeight;  // Default height of the AppBar
    final totalTopBarHeight = topPadding + appBarHeight;  // Calculate the total height of the top bar

    // Set the font size and logo size based on the totalTopBarHeight
    final textSize = topPadding * 0.7;  // Example proportion
    final logoSize = topPadding * 1;  // Example proportion

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/splash/splash.png',  // Ensure this path is correct
                height: logoSize,  // Set the logo size
              ),
              SizedBox(width: 8),  // Add some space between the logo and the text
              Text(
                'HearTheVision',
                style: TextStyle(
                  fontSize: textSize,  // Set the font size based on the calculated height
                  fontWeight: FontWeight.bold,  // Bold text
                  color: Colors.white,  // High-contrast text color
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.blueGrey,  // Attractive background color
      ),
      body: Stack(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned.fill( // Ensures the CameraPreview fills the stack
              child: CameraPreview(_cameraController!),
            ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          // Using a Container to wrap the button and expand it
          Container(
            width: screenWidth,  // Set the container width to screen width
            height: screenHeight,  // Set the container height to screen height
            child: GestureDetector(
              onTap: _handleTap,
              onLongPressStart: (details) => _handleLongPressStart(),
              onLongPressEnd: _handleLongPressEnd,
              child: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,  // No padding to cover the entire screen
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,  // No border radius to cover the entire screen
                  ),
                  side: BorderSide(color: Colors.blueGrey, width: 8),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.blueGrey, Colors.deepPurple],
                    tileMode: TileMode.mirror,
                  ).createShader(bounds),
                  child: Text(
                    ' Tap to Describe\nHold to Ask Question',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,  // Set font size based on screen width
                      color: Colors.white,  // The actual color doesn't matter when using ShaderMask
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

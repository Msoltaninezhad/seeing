// Import necessary Flutter package for UI components
import 'package:flutter/material.dart';
// Import Google ML Kit for text recognition capabilities
import 'package:google_ml_kit/google_ml_kit.dart';

// Define TextRecognitionScreen as a stateful widget
class TextRecognitionScreen extends StatefulWidget {
  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

// Define the state for TextRecognitionScreen
class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  // Create an instance of the text recognizer
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  // Variable to hold the recognized text
  String _recognizedText = '';

  // Method to recognize text from an input image
  void _recognizeText(InputImage inputImage) async {
    // Process the input image using the text recognizer
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    // Update the state with the recognized text
    setState(() {
      _recognizedText = recognizedText.text;
    });
  }

  // Dispose method to release resources when the widget is disposed
  @override
  void dispose() {
    // Close the text recognizer to free up resources
    _textRecognizer.close();
    super.dispose();
  }

  // Build method to construct the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Text Recognition')), // App bar title
      body: Column(
        children: [
          // Button to capture an image and recognize text
          ElevatedButton(
            onPressed: () {
              // Capture an image and call _recognizeText with the InputImage
            },
            child: Text('Capture and Recognize Text'), // Button text
          ),
          // Display the recognized text
          Text('Recognized Text: $_recognizedText'),
        ],
      ),
    );
  }
}

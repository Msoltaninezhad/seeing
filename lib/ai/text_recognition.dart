import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class TextRecognitionScreen extends StatefulWidget {
  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  String _recognizedText = '';

  void _recognizeText(InputImage inputImage) async {
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    setState(() {
      _recognizedText = recognizedText.text;
    });
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Text Recognition')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Capture an image and call _recognizeText with the InputImage
            },
            child: Text('Capture and Recognize Text'),
          ),
          Text('Recognized Text: $_recognizedText'),
        ],
      ),
    );
  }
}


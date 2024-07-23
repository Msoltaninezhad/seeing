import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:HearTheVisionG/ai/gemini_service.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final GeminiService _geminiService = GeminiService();
  String _response = '';
  bool _isLoading = false;

  void _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a dummy file path for testing
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/dummy_image.png';

      final response = await _geminiService.handleQuestionWithImage("Description", message, imagePath);
      setState(() {
        _response = response;
      });
      _speak(response);
    } catch (error) {
      setState(() {
        _response = 'Error: $error';
      });
      _speak('Failed to communicate with Gemini API.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with AI')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                labelText: 'Type your message',
              ),
            ),
          ),
          if (_isLoading)
            CircularProgressIndicator(),
          if (_response.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                _response,
                style: TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:visually_impaired_app/ai/chatgpt_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final ChatGPTService _chatGPTService = ChatGPTService();
  String _response = '';
  bool _isLoading = false;

  void _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _chatGPTService.generateDescription(message, ""); // Assuming you don't need imageBase64 here
      setState(() {
        _response = response;
      });
      _speak(response);
    } catch (error) {
      setState(() {
        _response = 'Error: $error';
      });
      _speak('Failed to communicate with ChatGPT.');
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
        children: [
          TextField(
            onSubmitted: _sendMessage,
            decoration: InputDecoration(
              labelText: 'Type your message',
            ),
          ),
          _isLoading
              ? CircularProgressIndicator()
              : Text(
            _response,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

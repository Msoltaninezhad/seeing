import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:HearTheVision/ai/chatgpt_service.dart';

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
      final response = await _chatGPTService.generateDescription(message, ""); // Assuming no imageBase64 is needed
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
          // Container(
          //   padding: EdgeInsets.all(8.0),
          //   height: 100, // Set a fixed height for the response container
          //   color: Colors.grey[200],
          //   child: SingleChildScrollView(
          //     child: Text(
          //       _response,
          //       style: TextStyle(fontSize: 18),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

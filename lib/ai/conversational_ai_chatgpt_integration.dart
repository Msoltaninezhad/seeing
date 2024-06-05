// Import necessary Flutter packages for UI components and TTS functionality
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
// Import the ChatGPT service for generating responses
import 'package:visually_impaired_app/ai/chatgpt_service.dart';

// Define ChatScreen as a stateful widget
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// Define the state for ChatScreen
class _ChatScreenState extends State<ChatScreen> {
  final FlutterTts _flutterTts = FlutterTts(); // Instance of FlutterTts for text-to-speech
  final ChatGPTService _chatGPTService = ChatGPTService(); // Instance of ChatGPTService for generating responses
  String _response = ''; // Variable to hold the response from ChatGPT
  bool _isLoading = false; // Variable to indicate if a response is being loaded

  // Method to send a message to ChatGPT and handle the response
  void _sendMessage(String message) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Generate a description from ChatGPT based on the message
      final response = await _chatGPTService.generateDescription(message, ""); // Assuming no imageBase64 is needed
      setState(() {
        _response = response; // Update the response state
      });
      _speak(response); // Speak the response using TTS
    } catch (error) {
      setState(() {
        _response = 'Error: $error'; // Handle errors by updating the response state
      });
      _speak('Failed to communicate with ChatGPT.'); // Speak an error message
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Method to speak the given text using TTS
  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Build method to construct the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with AI')), // App bar title
      body: Column(
        children: [
          // TextField to input and submit messages
          TextField(
            onSubmitted: _sendMessage, // Send message on submit
            decoration: InputDecoration(
              labelText: 'Type your message', // Input hint
            ),
          ),
          // Show a loading indicator or the response text
          _isLoading
              ? CircularProgressIndicator() // Show loading indicator if loading
              : Text(
            _response, // Display the response text
            style: TextStyle(fontSize: 18), // Text style
          ),
        ],
      ),
    );
  }
}

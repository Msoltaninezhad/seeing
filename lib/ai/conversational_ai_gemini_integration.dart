import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:HearTheVisionG/ai/gemini_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

// Initialize logger
var logger = Logger();

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FlutterTts _flutterTts = FlutterTts(); // Text-to-Speech instance
  final GeminiService _geminiService = GeminiService(); // AI service instance
  String _response = ''; // Variable to store AI response
  bool _isLoading = false; // Loading state indicator

  // Method to send a message to the AI service
  void _sendMessage(String message) async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      // Create a dummy file path for testing
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/dummy_image.jpg';

      // Log the image path for debugging
      logger.i('Image path: $imagePath');

      // Call the AI service with the message and dummy image path
      final response = await _geminiService.handleQuestionWithImage("Description", message, imagePath);
      setState(() {
        _response = response; // Update the response state with AI output
      });
      _speak(response); // Speak the AI response
    } catch (e) {
      // Log any errors that occur
      logger.e('Error occurred: $e');
      setState(() {
        _response = 'Error: $e'; // Update response state with error message
      });
      _speak('Failed to communicate with Gemini API.'); // Speak the error message
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false
      });
    }
  }

  // Method to speak text using Text-to-Speech
  void _speak(String text) async {
    try {
      await _flutterTts.speak(text); // Attempt to speak the text
    } catch (e) {
      // Log any errors that occur during TTS
      logger.e('TTS error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with AI')), // App bar title
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Layout the column with space between elements
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: _sendMessage, // Send message when the user submits the text field
              decoration: const InputDecoration(
                labelText: 'Type your message', // Placeholder text
              ),
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator(), // Show loading indicator if in loading state
          if (_response.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _response, // Display the AI response
                style: const TextStyle(fontSize: 18), // Style the response text
              ),
            ),
        ],
      ),
    );
  }
}

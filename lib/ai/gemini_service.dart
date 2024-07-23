import 'dart:typed_data';
import 'dart:io'; // Import for handling File
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey = 'AIzaSyDYWON8z6cx5Tz0r0gTVlyAsbP_T1bqsMw';

  final GenerativeModel model;

  GeminiService() : model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'AIzaSyDYWON8z6cx5Tz0r0gTVlyAsbP_T1bqsMw');

  // Future<void> sendInitialText() async {
  //   final prompt = "Hi Gemini.";
  //   print('Sending initial text: $prompt');

  //   try {
  //     final response = await model.generateContent([Content.text(prompt)]);
  //     print('Initial text response: ${response.candidates?.first.text ?? "No response generated"}');
  //   } catch (error) {
  //     print('Error occurred while sending initial text: $error');
  //     throw Exception('Failed to communicate with Gemini API: $error');
  //   }
  // }

  Future<String> generateDescription(String imagePath) async {
    // await sendInitialText(); // Send initial text first

    final prompt = "Describe the image directly to the user.";
    print('Prompt: $prompt');

    try {
      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      print('Image bytes length: ${imageBytes.length}');

      print('Sending request to Gemini API...');
      final response = await model.generateContent([
        Content.text(prompt),
        Content.data("image/png", imageBytes),
      ]);
      print('Response received from Gemini API.');
      print('Response: ${response.candidates?.first.text ?? "No description generated"}');
      return response.candidates?.first.text ?? "No description generated";
    } catch (error) {
      print('Error occurred: $error');
      throw Exception('Failed to communicate with Gemini API: $error');
    }
  }

  Future<String> handleQuestionWithImage(String description, String question, String imagePath) async {
    print('Description: $description');
    print('Question: $question');

    var prompt = 'Answer the following question concisely: "$question". Do not reference the user\'s blindness.';
    print('Prompt: $prompt');

    try {
      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      print('Image bytes length: ${imageBytes.length}');

      print('Sending request to Gemini API...');
      final response = await model.generateContent([
        Content.text(prompt),
        Content.data("image/png", imageBytes),
      ]);
      print('Response received from Gemini API.');
      print('Response: ${response.candidates?.first.text ?? "No answer generated"}');

      final String answer = response.candidates?.first.text ?? "No answer generated";

      if (answer.trim().isEmpty || answer.contains("I cannot answer that based on the provided description")) {
        return await generateDescription(imagePath);
      }

      return answer.trim();
    } catch (error) {
      print('Error occurred: $error');
      throw Exception('Failed to communicate with Gemini API: $error');
    }
  }

  Future<String> sendGeneralQuestion(String question) async {
    final prompt = 'Answer the following question concisely: "$question". Do not reference the user\'s blindness.';
    print('Prompt: $prompt');

    try {
      print('Sending general question to Gemini API...');
      final response = await model.generateContent([Content.text(prompt)]);
      print('Response received from Gemini API.');
      print('Response: ${response.candidates?.first.text ?? "No answer generated"}');
      return response.candidates?.first.text ?? "No answer generated";
    } catch (error) {
      print('Error occurred: $error');
      throw Exception('Failed to communicate with Gemini API: $error');
    }
  }
}

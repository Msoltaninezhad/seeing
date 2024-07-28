import 'dart:io'; // Import for handling File
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';

// Initialize logger
var logger = Logger();

class GeminiService {
  final String apiKey = 'AIzaSyDYWON8z6cx5Tz0r0gTVlyAsbP_T1bqsMw';
  final GenerativeModel model;

  GeminiService() : model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'AIzaSyDYWON8z6cx5Tz0r0gTVlyAsbP_T1bqsMw');

  Future<String> generateDescription(String imagePath) async {
    // Log the prompt being sent
    const prompt = "Describe the image directly to the user.";
    logger.i('Prompt: $prompt');

    try {
      // Attempt to read the image file
      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      logger.i('Image bytes length: ${imageBytes.length}');

      // Send request to Gemini API
      logger.i('Sending request to Gemini API...');
      final response = await model.generateContent([
        Content.text(prompt),
        Content.data("image/png", imageBytes),
      ]);
      logger.i('Response received from Gemini API.');
      logger.i('Response: ${response.candidates.first.text ?? "No description generated"}');
      return response.candidates.first.text ?? "No description generated";
    } catch (e) {
      // Specific error handling for file reading errors
      if (e is FileSystemException) {
        logger.e('File error: $e');
      } else if (e is HttpException) {
        logger.e('HTTP error: $e');
      } else {
        logger.e('Unexpected error: $e');
      }
      // Rethrow the error to ensure the caller is aware of the failure
      throw Exception('Failed to communicate with Gemini API: $e');
    }
  }

  Future<String> handleQuestionWithImage(String description, String question, String imagePath) async {
    // Log the description and question
    logger.i('Description: $description');
    logger.i('Question: $question');

    var prompt = 'Answer the following question concisely: "$question". Do not reference the user\'s blindness.';
    logger.i('Prompt: $prompt');

    try {
      // Attempt to read the image file
      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      logger.i('Image bytes length: ${imageBytes.length}');

      // Send request to Gemini API
      logger.i('Sending request to Gemini API...');
      final response = await model.generateContent([
        Content.text(prompt),
        Content.data("image/png", imageBytes),
      ]);
      logger.i('Response received from Gemini API.');
      logger.i('Response: ${response.candidates.first.text ?? "No answer generated"}');

      final String answer = response.candidates.first.text ?? "No answer generated";

      // Check the answer and fall back to description generation if needed
      if (answer.trim().isEmpty || answer.contains("I cannot answer that based on the provided description")) {
        return await generateDescription(imagePath);
      }

      return answer.trim();
    } catch (e) {
      // Specific error handling for file reading errors
      if (e is FileSystemException) {
        logger.e('File error: $e');
      } else if (e is HttpException) {
        logger.e('HTTP error: $e');
      } else {
        logger.e('Unexpected error: $e');
      }
      // Rethrow the error to ensure the caller is aware of the failure
      throw Exception('Failed to communicate with Gemini API: $e');
    }
  }

  Future<String> sendGeneralQuestion(String question) async {
    // Log the prompt being sent
    final prompt = 'Answer the following question concisely: "$question". Do not reference the user\'s blindness.';
    logger.i('Prompt: $prompt');

    try {
      // Send general question to Gemini API
      logger.i('Sending general question to Gemini API...');
      final response = await model.generateContent([Content.text(prompt)]);
      logger.i('Response received from Gemini API.');
      logger.i('Response: ${response.candidates.first.text ?? "No answer generated"}');
      return response.candidates.first.text ?? "No answer generated";
    } catch (e) {
      // Specific error handling for HTTP errors
      if (e is HttpException) {
        logger.e('HTTP error: $e');
      } else {
        logger.e('Unexpected error: $e');
      }
      // Rethrow the error to ensure the caller is aware of the failure
      throw Exception('Failed to communicate with Gemini API: $e');
    }
  }
}

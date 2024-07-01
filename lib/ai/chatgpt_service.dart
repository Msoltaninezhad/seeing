import 'dart:convert'; // For encoding and decoding JSON
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For loading environment variables

class ChatGPTService {
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  // The API key should be fetched from the .env file for security reasons
  // final String apiKey = dotenv.env['OPENAI_API_KEY']!;

  // Method to generate a description for an image
  Future<String> generateDescription(String prompt, String imageBase64) async {
    print('Prompt: $prompt');
    print('Image Base64: $imageBase64');

    var requestBody = {
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '$prompt Note: The user is blind.'
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$imageBase64'
              }
            }
          ]
        }
      ],
      'max_tokens': 300
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer sk-proj-HK7qSrfdod8XRiAmQHa6T3BlbkFJ90N58Y1QCu0flYstFDCM', // Use your own API key here
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String chatResponse = responseData['choices'][0]['message']['content'] ?? "No response from ChatGPT";
        return chatResponse.trim();
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to communicate with ChatGPT: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Failed to communicate with ChatGPT: $error');
    }
  }

  // Method to handle questions with image description
  Future<String> handleQuestionWithImage(String description, String question, String imageBase64) async {
    print('Description: $description');
    print('Question: $question');

    // First, check if the question can be answered based on the description
    var requestBody = {
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'user',
          'content': 'Answer the following question concisely: "$question". Avoid referencing the description or additional data. Note: The user is blind.'
        }
      ],
      'max_tokens': 300
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer sk-proj-HK7qSrfdod8XRiAmQHa6T3BlbkFJ90N58Y1QCu0flYstFDCM', // Use your own API key here
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String chatResponse = responseData['choices'][0]['message']['content'] ?? "No response from ChatGPT";

        // If the chatResponse does not contain an answer, reprocess the image
        if (chatResponse.trim().isEmpty || chatResponse.contains("I cannot answer that based on the provided description")) {
          // Reprocess the image
          return await generateDescription(question, imageBase64);
        }

        return chatResponse.trim();
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to communicate with ChatGPT: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Failed to communicate with ChatGPT: $error');
    }
  }
}

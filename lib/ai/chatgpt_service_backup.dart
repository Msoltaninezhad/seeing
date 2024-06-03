import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatGPTService {
  final String apiUrl = 'https://api.openai.com/v1/completions';
  // final String apiKey = dotenv.env['OPENAI_API_KEY']!;  // Get the API key from .env

  Future<String> generateDescription(String prompt) async {
    // print('Using API Key: $apiKey');  // Debugging: print the API key (remove this in production)
    print('Prompt: $prompt');  // Debugging: print the prompt
    Map<String, dynamic> requestBody = {
      'model': 'gpt-4o',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 150,
    };
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer sk-proj-HK7qSrfdod8XRiAmQHa6T3BlbkFJ90N58Y1QCu0flYstFDCM',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');  // Debugging: print response status
      print('Response body: ${response.body}');  // Debugging: print response body

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // final String chatResponse = responseData['choices'][0]['text'];
        final String chatResponse = responseData['choices'][0]['message']['content'] ?? "No response from ChatGPT";
        return chatResponse.trim();
      } else {
        print('Error response: ${response.body}');  // Debugging: print error response body
        throw Exception('Failed to communicate with ChatGPT: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');  // Debugging: print error
      throw Exception('Failed to communicate with ChatGPT: $error');
    }
  }
}

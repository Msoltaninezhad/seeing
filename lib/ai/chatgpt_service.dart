import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatGPTService {
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  // final String apiKey = dotenv.env['OPENAI_API_KEY']!;

  Future<String> generateDescription(String prompt, String imageBase64) async {
    print('Prompt: $prompt');  // Debugging: print the prompt
    print('Image Base64: $imageBase64');  // Debugging: print the image Base64 string


    var requestBody = {
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              // 'text': 'What’s in this image? Note: The user is blind.'
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
          'Authorization': 'Bearer sk-proj-HK7qSrfdod8XRiAmQHa6T3BlbkFJ90N58Y1QCu0flYstFDCM',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');  // Debugging: print response status
      print('Response body: ${response.body}');  // Debugging: print response body

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
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

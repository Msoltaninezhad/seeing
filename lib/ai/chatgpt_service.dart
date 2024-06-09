import 'dart:convert'; // For encoding and decoding JSON
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For loading environment variables

class ChatGPTService {
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  // The API key should be fetched from the .env file for security reasons (commented out here for illustration)
  // final String apiKey = dotenv.env['OPENAI_API_KEY']!;

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
}

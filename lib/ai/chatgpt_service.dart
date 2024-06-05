// Import necessary packages
import 'dart:convert'; // For encoding and decoding JSON
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For loading environment variables

// Define the ChatGPTService class
class ChatGPTService {
  // API endpoint for chat completions
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  // The API key should be fetched from the .env file for security reasons (commented out here for illustration)
  // final String apiKey = dotenv.env['OPENAI_API_KEY']!;

  // Method to generate a description based on the given prompt and image
  Future<String> generateDescription(String prompt, String imageBase64) async {
    // Debugging: print the prompt
    print('Prompt: $prompt');
    // Debugging: print the image Base64 string
    print('Image Base64: $imageBase64');

    // Create the request body as a map
    var requestBody = {
      'model': 'gpt-4o', // Specify the model to use
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              // Text prompt including a note that the user is blind
              'text': '$prompt Note: The user is blind.'
            },
            {
              'type': 'image_url',
              'image_url': {
                // Image URL embedded as a Base64 string
                'url': 'data:image/jpeg;base64,$imageBase64'
              }
            }
          ]
        }
      ],
      'max_tokens': 300 // Limit the number of tokens in the response
    };

    try {
      // Make a POST request to the OpenAI API
      final response = await http.post(
        Uri.parse(apiUrl), // API endpoint
        headers: {
          'Content-Type': 'application/json', // Set the content type to JSON
          'Authorization': 'Bearer sk-proj-HK7qSrfdod8XRiAmQHa6T3BlbkFJ90N58Y1QCu0flYstFDCM', // API key (should be secured)
        },
        body: jsonEncode(requestBody), // Encode the request body to JSON
      );

      // Debugging: print response status and body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check if the response status is OK
      if (response.statusCode == 200) {
        // Decode the response body
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Extract the chat response from the response data
        final String chatResponse = responseData['choices'][0]['message']['content'] ?? "No response from ChatGPT";
        return chatResponse.trim(); // Return the trimmed chat response
      } else {
        // Debugging: print error response body
        print('Error response: ${response.body}');
        // Throw an exception if the response status is not OK
        throw Exception('Failed to communicate with ChatGPT: ${response.statusCode}');
      }
    } catch (error) {
      // Debugging: print error
      print('Error: $error');
      // Throw an exception if an error occurs during the request
      throw Exception('Failed to communicate with ChatGPT: $error');
    }
  }
}

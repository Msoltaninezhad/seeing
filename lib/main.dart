import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioRecorderProvider(),
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _textController = TextEditingController();
  bool _isRecording = false;
  bool _isListening = false;
  String _transcription = "";
  String _imageBase64 = "";

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _generateAndSpeakWelcomeMessage();
  }

  @override
  void dispose() {
    _recorder.closeAudioSession();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openAudioSession();
  }

  Future<void> _generateAndSpeakWelcomeMessage() async {
    String welcomeMessage = "Hi,";
    await _speakMessage(welcomeMessage);
    await _testChatGPTConnection(); // Test ChatGPT connection
  }

  Future<void> _speakMessage(String message) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(message);
  }

  Future<void> _testChatGPTConnection() async {
    try {
      final response = await sendToChatGPT("Hi, my friend");
      await _speakMessage("ChatGPT response: $response");
    } catch (e) {
      print('Error: $e');
      await _speakMessage("Failed to communicate with ChatGPT.");
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      await _speakMessage("Recording started");
      _speech.listen(
        onResult: (val) => setState(() {
          _transcription = val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            _isListening = false;
            _speech.stop();
            _sendVoiceToChatGPT();
          }
        }),
      );
    }
  }

  Future<void> _stopListening() async {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _sendVoiceToChatGPT() async {
    String prompt = "User voice input.";
    try {
      final response = await sendToChatGPT(prompt, audio: _transcription);
      await _speakMessage(response);
    } catch (e) {
      print('Error: $e');
      await _speakMessage("Failed to communicate with ChatGPT.");
    }
  }

  Future<void> _sendTextToChatGPT() async {
    String prompt = _textController.text;
    try {
      final response = await sendToChatGPT(prompt);
      await _speakMessage(response);
    } catch (e) {
      print('Error: $e');
      await _speakMessage("Failed to communicate with ChatGPT.");
    }
  }

  Future<String> sendToChatGPT(String prompt, {String? audio}) async {
    Map<String, dynamic> requestBody = {
      'model': 'gpt-4o',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 150,
    };

    if (audio != null) {
      requestBody['audio'] = audio;
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer sk-proj-HK7qSrfdod8XRiAmQHa6T3BlbkFJ90N58Y1QCu0flYstFDCM',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['choices'][0]['message']['content'] ?? "No response from ChatGPT";
      } else {
        print('Failed to communicate with ChatGPT: ${response.statusCode} ${response.body}');
        throw Exception('Failed to communicate with ChatGPT');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to communicate with ChatGPT');
    }
  }

  Future<void> processImage(XFile image) async {
    final bytes = await image.readAsBytes();
    _imageBase64 = base64Encode(bytes);

    try {
      final response = await sendImageToGPT4o(_imageBase64);
      await _speakMessage(response);
    } catch (e) {
      print('Error processing image: $e');
      await _speakMessage("Failed to communicate with ChatGPT.");
    }
  }

  Future<String> sendImageToGPT4o(String base64Image) async {
    var requestBody = {
      'image': base64Image,
      'model': 'gpt-4o', // Use the correct model for vision tasks
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/edits'), // Use the correct endpoint for image processing
        headers: {
          'Authorization': 'Bearer sk-proj-HK7qSrfdod8XRiAmQHa6T3BlbkFJ90N58Y1QCu0flYstFDCM',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data'][0]['text'] ?? "No response from ChatGPT";
      } else {
        print('Failed to communicate with ChatGPT: ${response.statusCode} ${response.body}');
        throw Exception('Failed to communicate with ChatGPT');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to communicate with ChatGPT');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hear The Vision'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 200), // Make the button big
            ),
            onPressed: () async {
              await _speakMessage("Camera started");
              XFile? image = await _picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                await processImage(image);
              }
            },
            child: Text('Start Camera'),
          ),
          SizedBox(height: 20), // Add some space between buttons
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 200), // Make the button big
            ),
            onPressed: () async {
              if (!_isListening) {
                await _startListening();
              } else {
                await _stopListening();
              }
            },
            child: Text(_isListening ? 'Stop Listening' : 'Record Voice'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter text',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _sendTextToChatGPT,
            child: Text('Send Text'),
          ),
        ],
      ),
    );
  }
}

class AudioRecorderProvider with ChangeNotifier {
  File? _audioFile;

  File? get audioFile => _audioFile;

  void setAudioFile(File file) {
    _audioFile = file;
    notifyListeners();
  }
}
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
  final TextEditingController _questionController = TextEditingController();
  bool _isRecording = false;
  bool _isListening = false;
  String _transcription = "";
  String _imageBase64 = "";
  String _lastImageDescription = "";
  String _savedImagePath = "";

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
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openAudioSession();
  }

  Future<void> _generateAndSpeakWelcomeMessage() async {
    String welcomeMessage = "Starting";
    await _speakMessage(welcomeMessage);
    await _testChatGPTConnection();
  }

  Future<void> _speakMessage(String message) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(message);
  }

  Future<void> _testChatGPTConnection() async {
    try {
      final response = await sendToChatGPT("Just Say:( Hi Im here to be your eye)");
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
    String prompt = "User voice input: $_transcription";
    if (_lastImageDescription.isNotEmpty) {
      prompt = "User question about the image: $_transcription\nImage description: $_lastImageDescription";
    }
    try {
      final response = await sendToChatGPT(prompt);
      await _speakMessage(response);
    } catch (e) {
      print('Error: $e');
      await _speakMessage("Failed to communicate with ChatGPT.");
    }
  }

  Future<void> _sendTextToChatGPT() async {
    String prompt = _textController.text;
    if (_lastImageDescription.isNotEmpty) {
      prompt = "User question about the image: $prompt\nImage description: $_lastImageDescription";
    }
    try {
      final response = await sendToChatGPT(prompt);
      await _speakMessage(response);
    } catch (e) {
      print('Error: $e');
      await _speakMessage("Failed to communicate with ChatGPT.");
    }
  }

  Future<void> processImage(XFile image) async {
    final savedImagePath = await _saveImageLocally(image);
    setState(() {
      _savedImagePath = savedImagePath;
    });
    final bytes = await File(savedImagePath).readAsBytes();
    _imageBase64 = base64Encode(bytes);

    try {
      final response = await sendImageToGPT4o(_imageBase64);
      setState(() {
        _lastImageDescription = response;
      });
      await _speakMessage(response);
    } catch (e) {
      print('Error processing image: $e');
      await _speakMessage("Failed to communicate with ChatGPT.");
    }
  }

  Future<String> _saveImageLocally(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final File localImage = await File('$path/$fileName').writeAsBytes(await image.readAsBytes());
    return localImage.path;
  }

  Future<void> _loadAndProcessSavedImage() async {
    if (_savedImagePath.isNotEmpty) {
      final bytes = await File(_savedImagePath).readAsBytes();
      _imageBase64 = base64Encode(bytes);

      try {
        final response = await sendImageToGPT4o(_imageBase64);
        setState(() {
          _lastImageDescription = response;
        });
        await _speakMessage(response);
      } catch (e) {
        print('Error processing image: $e');
        await _speakMessage("Failed to communicate with ChatGPT.");
      }
    } else {
      await _speakMessage("No image saved yet.");
    }
  }

  Future<String> sendImageToGPT4o(String base64Image) async {
    var requestBody = {
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'What’s in this image?'
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image'
              }
            }
          ]
        }
      ],
      'max_tokens': 300
    };

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

  Future<void> _sendQuestionToChatGPT() async {
    if (_lastImageDescription.isEmpty) {
      await _speakMessage("No image has been described yet.");
      return;
    }

    String prompt = _questionController.text;
    prompt = "User question about the image: $prompt\nImage description: $_lastImageDescription";

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

  void _disconnectChatGPT() {
    _speakMessage("Disconnected from ChatGPT.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hear The Vision'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _disconnectChatGPT,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 200),
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
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 200),
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
          ElevatedButton(
            onPressed: _sendTextToChatGPT,
            child: Text('Send Text'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _questionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ask about the image',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _sendQuestionToChatGPT,
            child: Text('Ask Question'),
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

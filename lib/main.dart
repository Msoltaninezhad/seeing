import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

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
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _generateAndSpeakWelcomeMessage();
  }

  @override
  void dispose() {
    _recorder.closeAudioSession();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openAudioSession();
  }

  Future<void> _generateAndSpeakWelcomeMessage() async {
    String welcomeMessage = await _generateWelcomeMessage();
    await _speakMessage(welcomeMessage);
  }

  Future<String> _generateWelcomeMessage() async {
    String prompt = "Please generate a welcome message for a blind person. The message should say: 'Hi, I am your AI assistant. The app has two big buttons: one from the middle to the upper side of the screen for starting the camera, and one from the middle to the lower side for starting voice recording.'";

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/engines/davinci-codex/completions'),
      headers: {
        'Authorization': 'Bearer sk-proj-ti6a9826lYKHlD3kFKKYT3BlbkFJirlQcvxrrab6HjSWW7Le',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
        'max_tokens': 150,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['choices'][0]['text'];
    } else {
      throw Exception('Failed to generate welcome message');
    }
  }

  Future<void> _speakMessage(String message) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(message);
  }

  Future<String> sendToChatGPT(String text) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/engines/davinci-codex/completions'),
      headers: {
        'Authorization': 'Bearer sk-proj-ti6a9826lYKHlD3kFKKYT3BlbkFJirlQcvxrrab6HjSWW7Le',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': text,
        'max_tokens': 150,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['choices'][0]['text'];
    } else {
      throw Exception('Failed to communicate with ChatGPT');
    }
  }

  Future<String> speechToText(File audioFile) async {
    // This function should send the audio file to a speech-to-text API and return the transcribed text.
    // Replace with actual implementation.
    return "This is a transcribed text.";
  }

  Future<void> recordAndProcessVoice() async {
    if (!_isRecording) {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/audio.aac';
      await _recorder.startRecorder(
        toFile: tempPath,
      );
      setState(() {
        _isRecording = true;
      });
    } else {
      String? path = await _recorder.stopRecorder();
      if (path != null) {
        setState(() {
          _isRecording = false;
        });

        File audioFile = File(path);
        String transcribedText = await speechToText(audioFile);
        String chatGPTResponse = await sendToChatGPT(transcribedText);
        await _speakMessage(chatGPTResponse);
      }
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
              minimumSize: Size(double.infinity, 300), // Make the button big
            ),
            onPressed: () async {
              XFile? image = await _picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                // Process the image as needed
              }
            },
            child: Text('Start Camera'),
          ),
          SizedBox(height: 20), // Add some space between buttons
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity,300), // Make the button big
            ),
            onPressed: () async {
              await recordAndProcessVoice();
            },
            child: Text(_isRecording ? 'Stop Recording' : 'Record Voice'),
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

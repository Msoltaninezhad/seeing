import 'package:flutter_tts/flutter_tts.dart';

// Function to speak the welcome message
Future<void> WelcomeMessage() async {
  FlutterTts flutterTts = FlutterTts();

  await flutterTts.setLanguage('en-US');
  await flutterTts.setPitch(1.0);
  await flutterTts.setSpeechRate(0.5);
  await flutterTts.speak("Hello, I'm here to be your eye");
}

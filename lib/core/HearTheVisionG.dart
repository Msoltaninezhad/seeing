import 'package:flutter/material.dart';
import 'package:HearTheVisionG/ai/text_recognition.dart';
import 'package:HearTheVisionG/splash/splash_screen.dart';
import 'package:HearTheVisionG/core/home_screen.dart';
import 'package:HearTheVisionG/ai/conversational_ai_gemini_integration.dart';
import 'package:HearTheVisionG/splash/wellcome_message.dart';

class HearTheVisionG extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WelcomeMessage();

    return MaterialApp(
      title: 'Hear The Vision Assistant',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/text_recognition': (context) => TextRecognitionScreen(),
        '/chat': (context) => ChatScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

void main() {
  runApp(HearTheVisionG());
}
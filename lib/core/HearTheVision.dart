import 'package:flutter/material.dart';
import 'package:HearTheVision/ai/text_recognition.dart';
import 'package:HearTheVision/splash/splash_screen.dart';
import 'package:HearTheVision/core/home_screen.dart';
import 'package:HearTheVision/ai/conversational_ai_chatgpt_integration.dart';
import 'package:HearTheVision/splash/wellcome_message.dart';

class HearTheVision extends StatelessWidget {
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
  runApp(HearTheVision());
}

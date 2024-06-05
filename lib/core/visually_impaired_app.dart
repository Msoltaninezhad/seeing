import 'package:flutter/material.dart';
import 'package:visually_impaired_app/ai/text_recognition.dart';
import 'package:visually_impaired_app/splash/splash_screen.dart';
import 'package:visually_impaired_app/core/home_screen.dart';
import 'package:visually_impaired_app/ai/conversational_ai_chatgpt_integration.dart';
import 'package:visually_impaired_app/splash/wellcome_message.dart';



class VisuallyImpairedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WelcomeMessage(); // Call the WelcomeMessage function
    return MaterialApp(
      title: 'Visually Impaired Assistant',
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
  runApp(VisuallyImpairedApp());
}

import 'package:flutter/material.dart';
import 'package:visually_impaired_app/ai/text_recognition.dart';
import 'package:visually_impaired_app/splash/splash_screen.dart';
import 'package:visually_impaired_app/core/home_screen.dart';
import 'package:visually_impaired_app/ai/conversational_ai_chatgpt_integration.dart';

class VisuallyImpairedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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


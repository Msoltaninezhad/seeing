import 'package:flutter/material.dart';
import 'package:HearTheVisionG/ai/text_recognition.dart';
import 'package:HearTheVisionG/splash/splash_screen.dart';
import 'package:HearTheVisionG/core/home_screen.dart';
import 'package:HearTheVisionG/ai/conversational_ai_gemini_integration.dart';
import 'package:HearTheVisionG/splash/welcome_message.dart';

/// The main widget that initializes and runs the HearTheVisionG application.
class HearTheVisionG extends StatelessWidget {
  /// Constructor with an optional key parameter for widget identification.
  const HearTheVisionG({super.key});

  @override
  Widget build(BuildContext context) {
    // Plays a welcome message upon application start.
    WelcomeMessage();

    return MaterialApp(
      title: 'Hear The Vision Assistant', // Application title
      initialRoute: '/', // Sets the initial route
      routes: {
        '/': (context) => const SplashScreen(), // Route for splash screen
        '/home': (context) => const HomeScreen(), // Route for home screen
        '/text_recognition': (context) => TextRecognitionScreen(), // Route for text recognition screen
        '/chat': (context) => ChatScreen(), // Route for chat screen
      },
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color theme
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adaptive density for various platforms
      ),
    );
  }
}

/// The main entry point for the Flutter application.
void main() {
  runApp(const HearTheVisionG());
}

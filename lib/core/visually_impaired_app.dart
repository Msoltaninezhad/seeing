// Import the necessary Flutter material package for UI components
import 'package:flutter/material.dart';

// Import custom packages for different functionalities of the app
import 'package:visually_impaired_app/ai/text_recognition.dart';
import 'package:visually_impaired_app/splash/splash_screen.dart';
import 'package:visually_impaired_app/core/home_screen.dart';
import 'package:visually_impaired_app/ai/conversational_ai_chatgpt_integration.dart';
import 'package:visually_impaired_app/splash/wellcome_message.dart';

// Define the main application class which is a stateless widget
class VisuallyImpairedApp extends StatelessWidget {
  // Override the build method to construct the widget tree
  @override
  Widget build(BuildContext context) {
    // Display a welcome message (possibly a function that shows a dialog or prints a message)
    WelcomeMessage();

    // Return a MaterialApp widget which is the root of the application
    return MaterialApp(
      // Set the title of the application
      title: 'Visually Impaired Assistant',
      // Define the initial route when the app starts
      initialRoute: '/',
      // Define the route mappings for navigation
      routes: {
        // The initial route (home screen)
        '/': (context) => SplashScreen(),
        // The home screen route
        '/home': (context) => HomeScreen(),
        // The text recognition screen route
        '/text_recognition': (context) => TextRecognitionScreen(),
        // The chat screen route (for conversational AI)
        '/chat': (context) => ChatScreen(),
      },
      // Define the theme of the application
      theme: ThemeData(
        // Set the primary color swatch
        primarySwatch: Colors.blue,
        // Set the visual density to adapt to different platforms
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

// The main function which is the entry point of the application
void main() {
  // Run the application
  runApp(VisuallyImpairedApp());
}

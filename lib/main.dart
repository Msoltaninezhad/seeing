// Flutter imports
import 'package:flutter/material.dart';
// Third-party package imports
import 'package:flutter_gemini/flutter_gemini.dart';
// Project imports
import 'package:HearTheVisionG/core/hear_the_vision_g.dart';
import 'package:logger/logger.dart';

// Create a logger instance
final logger = Logger();

void main() async {
  try {
    Gemini.init(apiKey: 'AIzaSyDYWON8z6cx5Tz0r0gTVlyAsbP_T1bqsMw');
    runApp(const HearTheVisionG());
  } catch (error) {
    // Log the initialization error
    logger.e('Initialization failed', error);
  }
}


// Flutter imports
import 'package:flutter/material.dart';
// Third-party package imports
import 'package:flutter_gemini/flutter_gemini.dart';
// Project imports
import 'package:HearTheVisionG/core/HearTheVisionG.dart';

void main() async {
  try {
    await Gemini.init(apiKey: 'AIzaSyDYWON8z6cx5Tz0r0gTVlyAsbP_T1bqsMw');
    runApp(HearTheVisionG());
  } catch (error) {
    // Handle initialization error (e.g., log it, show a message, etc.)
    print('Initialization failed: $error');
  }
}

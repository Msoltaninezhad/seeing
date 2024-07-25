import 'dart:io';
import 'package:flutter/material.dart';
import 'package:HearTheVisionG/core/HearTheVisionG.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  Gemini.init(apiKey: 'AIzaSyDYWON8z6cx5Tz0r0gTVlyAsbP_T1bqsMw');
  runApp(HearTheVisionG());
}
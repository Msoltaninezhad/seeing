import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:visually_impaired_app/core/visually_impaired_app.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();  // Ensure widgets are bound before dotenv is loaded
  // await dotenv.load(fileName: ".env");  // Load the .env file
  runApp(VisuallyImpairedApp());
}

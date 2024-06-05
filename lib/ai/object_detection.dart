import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; // Updated package import

class ObjectDetection {
  final Interpreter _interpreter; // Add an Interpreter field to manage model

  ObjectDetection._(this._interpreter); // Update constructor to accept interpreter

  static Future<ObjectDetection> create() async {
    // Load the model with Interpreter
    final interpreter = await Interpreter.fromAsset('mobilenet_ssd.tflite');
    return ObjectDetection._(interpreter);
  }

  Future<List<Map<String, dynamic>>> detectObjects(String imagePath) async {
    var recognitions = await _detectObjects(imagePath); // Refactor detection logic into a new method
    if (recognitions == null) {
      return [];
    }

    return recognitions.map((rec) {
      return {
        'label': rec['detectedClass'],
        'confidence': rec['confidenceInClass'],
        'rect': rec['rect'],
      };
    }).toList();
  }

  Future<List<dynamic>> _detectObjects(String imagePath) async {
    // Perform inference using TensorFlow Lite
    // You might need to modify this depending on how your model processes input and output
    var imageBytes = (await rootBundle.load(imagePath)).buffer.asUint8List();
    var output = List<double>.filled(1 * 10 * 4, 0); // Adjust the size based on your model's output
    _interpreter.run(imageBytes, output);
    return output;
  }

  void close() {
    _interpreter.close(); // Properly close the interpreter
  }
}

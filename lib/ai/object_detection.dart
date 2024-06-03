import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:tflite/tflite.dart';

class ObjectDetection {
  ObjectDetection._();

  static Future<ObjectDetection> create() async {
    final objectDetection = ObjectDetection._();

    // Load the model
    String? res = await Tflite.loadModel(
      model: "assets/mobilenet_ssd.tflite",
      labels: "assets/labels.txt",
    );

    if (res != "success") {
      throw Exception('Failed to load the model');
    }

    return objectDetection;
  }

  Future<List<Map<String, dynamic>>> detectObjects(String imagePath) async {
    var recognitions = await Tflite.detectObjectOnImage(
      path: imagePath,
      model: "SSDMobileNet",
      threshold: 0.5,
      numResultsPerClass: 10,
    );

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

  void close() {
    Tflite.close();
  }
}

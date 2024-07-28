import 'package:camera/camera.dart';
import 'package:logger/logger.dart';

/// Service to manage the camera controller, including initialization and disposal.
class CameraControllerService {
  CameraController? _cameraController;  // Camera controller instance
  final Logger logger = Logger();  // Logger instance for logging messages

  /// Initializes the camera by selecting the first available camera and setting
  /// the resolution to high. Logs the status of the initialization.
  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();  // Fetches the list of available cameras
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(cameras[0], ResolutionPreset.high);  // Selects the first camera
        await _cameraController?.initialize();  // Initializes the camera controller

        if (_cameraController != null && _cameraController!.value.isInitialized) {
          logger.i('Camera initialized with resolution: ${_cameraController!.value.previewSize}');
        } else {
          logger.e('Failed to initialize the camera.');
        }
      } else {
        logger.e('No cameras available.');
      }
    } catch (e) {
      logger.e('Error initializing camera: $e');
    }
  }

  /// Getter for the camera controller instance.
  CameraController? get cameraController => _cameraController;

  /// Disposes the camera controller to free up resources.
  void dispose() {
    _cameraController?.dispose();
  }
}

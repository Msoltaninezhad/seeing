import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Service to manage the camera controller, including initialization and disposal.
class CameraControllerService {
  CameraController? _cameraController;  // Camera controller instance
  final Logger logger = Logger();  // Logger instance for logging messages

  static const String esp32CamUrl = 'http://your_esp32_cam_ip';  // Replace with your ESP32 cam IP address

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

  /// Attempts to fetch an image from the ESP32 cam.
  Future<XFile?> _fetchImageFromEsp32Cam() async {
    try {
      final response = await http.get(Uri.parse('$esp32CamUrl/capture'));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final file = XFile.fromData(
          bytes,
          mimeType: 'image/jpeg',
          name: 'esp32_cam_image.jpg',
        );
        logger.i('Image fetched from ESP32 cam.');
        return file;
      } else {
        logger.e('Failed to fetch image from ESP32 cam. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching image from ESP32 cam: $e');
      return null;
    }
  }

  /// Takes a picture, first trying to fetch from the ESP32 cam, then falling back to the mobile camera if necessary.
  Future<XFile?> takePicture() async {
    XFile? picture = await _fetchImageFromEsp32Cam();
    if (picture != null) {
      return picture;
    }

    // Fallback to mobile camera if ESP32 cam is not available
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController?.setFlashMode(FlashMode.auto);  // Sets the flash mode to auto
        picture = await _cameraController!.takePicture();  // Takes a picture and returns an XFile
        await _cameraController?.setFlashMode(FlashMode.off);  // Turns off the flash after taking the picture
        logger.i('Picture taken with mobile camera and flash turned off.');
        return picture;
      } catch (e) {
        logger.e('Error taking picture with mobile camera: $e');
        return null;
      }
    } else {
      logger.e('Camera controller is not initialized.');
      return null;
    }
  }

  /// Getter for the camera controller instance.
  CameraController? get cameraController => _cameraController;

  /// Disposes the camera controller to free up resources.
  void dispose() {
    _cameraController?.dispose();
  }
}

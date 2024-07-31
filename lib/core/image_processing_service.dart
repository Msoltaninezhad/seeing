import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

/// Service for handling image processing tasks such as capturing and saving images.
class ImageProcessingService {
  final Logger logger = Logger();  // Logger instance for logging messages

  /// Captures an image using the provided camera controller and saves it to the application documents directory.
  ///
  /// Returns the path to the saved image if successful, or null if an error occurs.
  Future<String?> captureAndSaveImage(CameraController cameraController) async {
    try {
      // Capture the picture using the camera controller
      final XFile picture = await cameraController.takePicture();

      // Get the application documents directory to save the image
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/captured_image.jpg'; // Save as .jpg

      // Save the captured image to the defined path
      await picture.saveTo(imagePath);

      // Log the success of the image capture and save
      logger.i('Image captured and saved to $imagePath');
      logger.i('Image MIME type: image/jpeg'); // Updated to match .jpg

      return imagePath;
    } catch (error) {
      // Log any errors that occur during the capture and save process
      logger.e('Error capturing and saving image: $error');
      return null;
    }
  }
}

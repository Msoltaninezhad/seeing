import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';

class HardwareCameraControl {
  final Logger logger = Logger();
  late WebSocketChannel channel;

  /// Initialize WebSocket connection to the ESP32 camera.
  void initializeWebSocket(String ipAddress) {
    const String websocketUrl = 'ws://192.168.229.70:81';
    channel = WebSocketChannel.connect(Uri.parse(websocketUrl));

    logger.i('WebSocket connection initialized at $websocketUrl');

    // Listen for messages from the WebSocket server
    channel.stream.listen(
          (message) {
        logger.i('Received message from WebSocket: $message');
      },
      onError: (error) {
        logger.e('WebSocket error: $error');
      },
      onDone: () {
        logger.i('WebSocket connection closed');
      },
    );
  }

  /// Capture image by sending a command to the ESP32 camera over WebSocket.
  void captureImage() {
    logger.i('Sending capture_image command to ESP32 camera');
    channel.sink.add('capture_image');
  }

  /// Close the WebSocket connection properly.
  void closeWebSocket() {
    channel.sink.close();
    logger.i('WebSocket connection closed');
  }
}

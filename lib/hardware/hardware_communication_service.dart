import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';

class HardwareCommunicationService {
  final Logger logger = Logger();
  late WebSocketChannel channel;

  /// Initialize WebSocket connection to the ESP32 device.
  void initializeWebSocket(String ipAddress) {
    const String websocketUrl = 'ws://192.168.229.70:81';
    channel = WebSocketChannel.connect(Uri.parse(websocketUrl));

    logger.i('WebSocket connection initialized at $websocketUrl');

    // Listen for incoming messages from the ESP32
    channel.stream.listen(
          (message) {
        logger.i('Received message from WebSocket: $message');
        _handleMessage(message);
      },
      onError: (error) {
        logger.e('WebSocket error: $error');
      },
      onDone: () {
        logger.i('WebSocket connection closed');
      },
    );
  }

  /// Send a command to the ESP32, such as 'capture_image'.
  void sendCommand(String command) {
    logger.i('Sending command to ESP32: $command');
    channel.sink.add(command);
  }

  /// Handle incoming messages from the ESP32
  void _handleMessage(String message) {
    if (message.contains('short_press')) {
      logger.i('Short press detected from ESP32');
      // Trigger action based on short press
    } else if (message.contains('long_press')) {
      logger.i('Long press detected from ESP32');
      // Trigger action based on long press
    } else if (message.contains('image_data')) {
      logger.i('Image data received from ESP32');
      // Handle image data
      _processImageData(message);
    } else {
      logger.w('Unexpected message received: $message');
    }
  }

  /// Process the image data received from the ESP32
  void _processImageData(String imageData) {
    // Convert and process the image data as needed
    logger.i('Processing image data');
    // TODO: Add image processing logic here
  }

  /// Close the WebSocket connection properly.
  void closeWebSocket() {
    channel.sink.close();
    logger.i('WebSocket connection closed');
  }
}

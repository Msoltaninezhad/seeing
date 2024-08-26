import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';

class HardwareButtonControl {
  final Logger logger = Logger();
  late WebSocketChannel channel;

  /// Initialize WebSocket connection to the ESP32 button control.
  void initializeWebSocket(String ipAddress) {
    const String websocketUrl = 'ws://192.168.229.70:81';
    channel = WebSocketChannel.connect(Uri.parse(websocketUrl));

    logger.i('WebSocket connection initialized at $websocketUrl');

    // Listen for button press messages from the ESP32
    channel.stream.listen(
          (message) {
        if (message == 'short_press') {
          logger.i('Short press detected from ESP32 button');
          // Handle short press action
        } else if (message == 'long_press') {
          logger.i('Long press detected from ESP32 button');
          // Handle long press action
        } else {
          logger.w('Received unexpected message: $message');
        }
      },
      onError: (error) {
        logger.e('WebSocket error: $error');
      },
      onDone: () {
        logger.i('WebSocket connection closed');
      },
    );
  }

  /// Close the WebSocket connection properly.
  void closeWebSocket() {
    channel.sink.close();
    logger.i('WebSocket connection closed');
  }
}

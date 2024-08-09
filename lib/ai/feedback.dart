import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

class FeedbackService {
  final Logger _logger = Logger();

  /// Function to send feedback via email
  Future<void> sendFeedback(String feedbackText) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'msoltaniinezhad@gmail.com',
      queryParameters: {
        'subject': 'User Feedback',
        'body': feedbackText,
      },
    );

    try {
      if (await canLaunch(emailLaunchUri.toString())) {
        await launch(emailLaunchUri.toString());
        _logger.i('Feedback email launched successfully.');
      } else {
        _logger.e('Could not launch feedback email.');
      }
    } catch (error) {
      _logger.e('Error launching email client: $error');
    }
  }
}

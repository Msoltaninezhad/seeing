import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Service for building UI components such as the AppBar and the main body of the screen.
class UIService {
  /// Builds the AppBar with the specified padding, logo size, and text size.
  ///
  /// Returns a PreferredSizeWidget that can be used as the AppBar.
  PreferredSizeWidget buildAppBar(double topPadding, double logoSize, double textSize) {
    return AppBar(
      title: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/splash/splash.png',  // Path to the logo image
              height: logoSize,
            ),
            const SizedBox(width: 8),
            Text(
              'HearTheVision',
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey,
    );
  }

  /// Builds the main body of the screen with the specified parameters.
  ///
  /// The body includes the camera preview, a loading indicator, and a button with tap and long press actions.
  Widget buildBody({
    required CameraController? cameraController,
    required bool isLoading,
    required double screenWidth,
    required double screenHeight,
    required Function() onTap,
    required Function(LongPressStartDetails) onLongPressStart,
    required Function(LongPressEndDetails) onLongPressEnd,
  }) {
    return Stack(
      children: [
        if (cameraController != null && cameraController.value.isInitialized)
          Positioned.fill(
            child: CameraPreview(cameraController),  // Display the camera preview if initialized
          ),
        if (isLoading)
          const Center(child: CircularProgressIndicator()),  // Display a loading indicator if loading
        SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: GestureDetector(
            onTap: onTap,
            onLongPressStart: onLongPressStart,
            onLongPressEnd: onLongPressEnd,
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                side: const BorderSide(color: Colors.blueGrey, width: 8),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.blueGrey, Colors.deepPurple],
                  tileMode: TileMode.mirror,
                ).createShader(bounds),
                child: Text(
                  ' Tap to Describe\nHold to Ask Question',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

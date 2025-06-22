import 'package:flutter/material.dart';

class ScreenWithLoader extends StatelessWidget {
  final bool isLoading;
  final Widget body;
  final Color loaderBackgroundColor;
  final Color loaderColor;
  final String loadingText;
  final TextStyle loadingTextStyle;
  final double loaderSize;

  ScreenWithLoader({
    required this.isLoading,
    required this.body,
    this.loaderBackgroundColor = Colors.black54,
    this.loaderColor = Colors.white,
    this.loadingText = 'Loading...',
    this.loadingTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    this.loaderSize = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        body,
        if (isLoading)
          Container(
            color: loaderBackgroundColor,
            child: Center(
              child: Container(
                width: loaderSize,
                height: loaderSize,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(loaderColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loadingText,
                      textAlign: TextAlign.center,
                      style: loadingTextStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
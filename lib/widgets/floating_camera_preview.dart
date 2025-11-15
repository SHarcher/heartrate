import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class FloatingCameraPreview extends StatelessWidget {
  final CameraController controller;
  final VoidCallback onTap;

  const FloatingCameraPreview({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: CameraPreview(controller),
      ),
    );
  }
}

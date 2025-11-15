import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraFullscreenPage extends StatelessWidget {
  final CameraController controller;

  const CameraFullscreenPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Camera Preview"),
      ),
      body: Center(
        child: CameraPreview(controller),
      ),
    );
  }
}

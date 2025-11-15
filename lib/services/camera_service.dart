import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

typedef FrameCallback = void Function(CameraImage image);

class CameraService {
  CameraController? _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize(FrameCallback onFrame) async {
    if (kIsWeb) return; // Web not supported

    final cams = await availableCameras();
    final front = cams.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cams.first,
    );

    _controller = CameraController(
      front,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    await _controller!.startImageStream(onFrame);
  }

  CameraController? get controller => _controller;

  void dispose() {
    _controller?.dispose();
  }
}

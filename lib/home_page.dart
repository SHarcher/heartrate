import 'package:flutter/material.dart';
import 'pages/camera_fullscreen_page.dart';
import 'widgets/heart_rate_card.dart';
import '../services/camera_service.dart';
import '../core/heart_rate_engine.dart';
import 'widgets/floating_camera_preview.dart';
import 'package:camera/camera.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? bpm;
  double? quality;

  late HeartRateEngine _engine;
  late CameraService _cameraService;

  bool showFloatingCamera = false;

  bool _processingFrame = false;

  @override
  void initState() {
    super.initState();

    _engine = HeartRateEngine(
      onUpdate: (b, q) {
        setState(() {
          bpm = b;
          quality = q;
        });
      },
    );

    _cameraService = CameraService();
  }

  /// Process a camera frame for heart rate extraction
  void _onFrame(CameraImage img) {
    if (_processingFrame) return;
    _processingFrame = true;

    try {
      if (img.format.group != ImageFormatGroup.bgra8888 || img.planes.isEmpty) {
        _processingFrame = false;
        return;
      }

      final p = img.planes[0];
      final bytes = p.bytes;

      final width = img.width;
      final height = img.height;

      final roi = (width * 0.4).round();
      final x0 = (width - roi) ~/ 2;
      final y0 = (height - roi) ~/ 2;

      double sumR = 0, sumG = 0, sumB = 0;
      int count = 0;

      final bytesPerPixel = 4;
      final rowStride = p.bytesPerRow;

      for (int y = y0; y < y0 + roi; y += 4) {
        final row = y * rowStride;
        for (int x = x0; x < x0 + roi; x += 4) {
          final idx = row + x * bytesPerPixel;
          if (idx + 2 >= bytes.length) continue;

          sumB += bytes[idx];
          sumG += bytes[idx + 1];
          sumR += bytes[idx + 2];
          count++;
        }
      }

      if (count > 0) {
        _engine.addSample(
          sumR / count,
          sumG / count,
          sumB / count,
          DateTime.now(),
        );
      }
    } finally {
      Future.delayed(const Duration(milliseconds: 25), () {
        _processingFrame = false;
      });
    }
  }

  Future<void> startMeasurement() async {
    if (!_cameraService.isInitialized) {
      await _cameraService.initialize(_onFrame);
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraService.controller;

    return Scaffold(
      appBar: AppBar(title: const Text("Heart Rate Home")),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeartRateCard(bpm: bpm, quality: quality),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.favorite),
                label: const Text("Measure"),
                onPressed: startMeasurement,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera"),
                onPressed: () async {
                  await startMeasurement(); // ensure camera running
                  setState(() => showFloatingCamera = true);
                },
              ),
            ],
          ),
          if (showFloatingCamera && controller != null)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingCameraPreview(
                controller: controller,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CameraFullscreenPage(
                        controller: controller,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

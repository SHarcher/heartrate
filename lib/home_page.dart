import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';

import 'pages/camera_fullscreen_page.dart';
import 'widgets/floating_camera_preview.dart';
import 'widgets/heart_rate_card.dart';

import '../services/camera_service.dart';
import '../core/heart_rate_engine.dart';
import '../core/heart_rate_adapter.dart';

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

  // Position of the draggable floating preview.
  Offset floatingPos = const Offset(20, 500);

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

  // ---------------------------------------------------------------------------
  // MOBILE FRAME HANDLER
  // ---------------------------------------------------------------------------
  void _onFrameMobile(CameraImage img) {
    if (_processingFrame) return;
    _processingFrame = true;

    try {
      HeartRateAdapter.processMobileFrame(img, _engine);
    } finally {
      // Simple throttle to avoid overloading computation.
      Future.delayed(const Duration(milliseconds: 25), () {
        _processingFrame = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // WEB FRAME HANDLER
  // ---------------------------------------------------------------------------
  void _onFrameWeb(Uint8ClampedList rgba, int w, int h) {
    HeartRateAdapter.processWebFrame(rgba, w, h, _engine);
  }

  // ---------------------------------------------------------------------------
  // START MEASUREMENT
  // ---------------------------------------------------------------------------
  Future<void> startMeasurement() async {
    if (!_cameraService.isInitialized) {
      await _cameraService.initialize(
        onFrameMobile: _onFrameMobile,
        onFrameWeb: _onFrameWeb,
      );
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
          // Main content (heart rate display + buttons)
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
                  await startMeasurement();
                  setState(() => showFloatingCamera = true);
                },
              ),
            ],
          ),

          // Draggable floating camera preview
          if (showFloatingCamera)
            Positioned(
              left: floatingPos.dx,
              top: floatingPos.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    floatingPos += details.delta;
                  });
                },
                child: FloatingCameraPreview(
                  controller: controller,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CameraFullscreenPage(
                          controller: controller,
                          onMinimize: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

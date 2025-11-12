import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class MeasurePage extends StatefulWidget {
  final CameraDescription camera;
  const MeasurePage({super.key, required this.camera});

  @override
  State<MeasurePage> createState() => _MeasurePageState();
}

class _MeasurePageState extends State<MeasurePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Timer? _loopTimer;

  bool _isCameraOn = false;
  int _heartRate = 0;
  int _respirationRate = 0;

  @override
  void initState() {
    super.initState();
    // Delay initialization to ensure the widget is fully built before camera starts
    Future.delayed(const Duration(milliseconds: 300), _initializeCamera);
  }

  Future<void> _initializeCamera() async {
    print('🎥 Initializing camera...');
    try {
      _controller = CameraController(
        widget.camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() => _isCameraOn = true);
      }

      print('✅ Camera initialized successfully.');
      // Start measurement loop
      _startMeasurement();
    } catch (e) {
      print('❌ Camera initialization failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e')),
        );
      }
    }
  }

  void _startMeasurement() {
    print('📈 Starting fake measurement loop (replace with real API later)...');
    _loopTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Simulated values; replace with VitalLens API call
      setState(() {
        _heartRate = 60 + (timer.tick % 20);
        _respirationRate = 15 + (timer.tick % 5);
      });
    });
  }

  Future<void> _stopMeasurement() async {
    print('🛑 Stopping measurement...');
    _loopTimer?.cancel();
    if (_controller.value.isInitialized) {
      await _controller.dispose();
    }
    setState(() => _isCameraOn = false);

    if (mounted) {
      Navigator.pop(context); // ✅ Automatically return to HomePage
    }
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Measuring Heart Rate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
            tooltip: 'Stop Measurement',
            onPressed: _stopMeasurement,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && _isCameraOn) {
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller)),
                Positioned(
                  top: 40,
                  left: 20,
                  child: _infoBox('❤️ Heart Rate', '$_heartRate bpm'),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: _infoBox('💨 Respiration', '$_respirationRate bpm'),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to start camera: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

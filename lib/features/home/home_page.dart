import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../measure/measure_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _goToMeasurePage(BuildContext context) async {
    print('✅ Button pressed');
    try {
      final cameras = await availableCameras();

      // 🔄 Select front camera instead of rear
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      print('✅ Selected camera: ${frontCamera.lensDirection}');
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeasurePage(camera: frontCamera),
          ),
        );
      }
    } catch (e) {
      print('❌ Failed to initialize camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to access camera: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('VitalLens Heart Rate Demo')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _goToMeasurePage(context),
          icon: const Icon(Icons.favorite, color: Colors.white),
          label: const Text('Start Measurement'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}

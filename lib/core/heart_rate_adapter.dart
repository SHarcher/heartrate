import 'dart:typed_data';
import 'package:camera/camera.dart';

import 'heart_rate_engine.dart';

class HeartRateAdapter {
  /// Process a mobile frame (CameraImage BGRA8888) and feed into the given engine.
  static void processMobileFrame(
    CameraImage img,
    HeartRateEngine engine,
  ) {
    if (img.format.group != ImageFormatGroup.bgra8888 || img.planes.isEmpty) {
      return;
    }

    final plane = img.planes[0];
    final bytes = plane.bytes;

    final width = img.width;
    final height = img.height;
    final stride = plane.bytesPerRow;

    // Sample a small region around the center for faster computation.
    final roiSize = (width * 0.4).round();
    final x0 = (width - roiSize) ~/ 2;
    final y0 = (height - roiSize) ~/ 2;

    double sumR = 0, sumG = 0, sumB = 0;
    int count = 0;

    for (int y = y0; y < y0 + roiSize; y += 4) {
      final row = y * stride;
      for (int x = x0; x < x0 + roiSize; x += 4) {
        final idx = row + x * 4;
        if (idx + 2 >= bytes.length) continue;

        final b = bytes[idx].toDouble();
        final g = bytes[idx + 1].toDouble();
        final r = bytes[idx + 2].toDouble();

        sumR += r;
        sumG += g;
        sumB += b;
        count++;
      }
    }

    if (count == 0) return;

    final avgR = sumR / count;
    final avgG = sumG / count;
    final avgB = sumB / count;

    engine.addSample(avgR, avgG, avgB, DateTime.now());
  }

  /// Process a web frame (RGBA Uint8ClampedList) and feed into the given engine.
  static void processWebFrame(
    Uint8ClampedList rgbaBytes,
    int width,
    int height,
    HeartRateEngine engine,
  ) {
    if (width <= 0 || height <= 0) return;

    final cx = width ~/ 2;
    final cy = height ~/ 2;
    final index = (cy * width + cx) * 4;

    if (index + 2 >= rgbaBytes.length) return;

    final r = rgbaBytes[index].toDouble();
    final g = rgbaBytes[index + 1].toDouble();
    final b = rgbaBytes[index + 2].toDouble();

    engine.addSample(r, g, b, DateTime.now());
  }
}

import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html; // Web-only (ignored on mobile compilation)

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

typedef FrameCallbackMobile = void Function(CameraImage image);
typedef FrameCallbackWeb = void Function(
  Uint8ClampedList rgbaBytes,
  int width,
  int height,
);

class CameraService {
  CameraController? _controller;

  // Web-only fields
  html.VideoElement? _webVideo;
  html.CanvasElement? _webCanvas;
  html.CanvasRenderingContext2D? _webCtx;
  Timer? _webFrameTimer;
  bool _webReady = false;

  bool get isInitialized {
    if (kIsWeb) return _webReady;
    return _controller?.value.isInitialized ?? false;
  }

  /// Unified initialization for mobile & web
  Future<void> initialize({
    FrameCallbackMobile? onFrameMobile,
    FrameCallbackWeb? onFrameWeb,
  }) async {
    if (kIsWeb) {
      if (onFrameWeb == null) {
        throw ArgumentError("onFrameWeb must not be null on Web.");
      }
      return _initializeWeb(onFrameWeb);
    } else {
      if (onFrameMobile == null) {
        throw ArgumentError("onFrameMobile must not be null on Mobile.");
      }
      return _initializeMobile(onFrameMobile);
    }
  }

  // ---------------------------------------------------------------------------
  // MOBILE INITIALIZATION
  // ---------------------------------------------------------------------------
  Future<void> _initializeMobile(FrameCallbackMobile onFrame) async {
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

  // ---------------------------------------------------------------------------
  // WEB INITIALIZATION
  // ---------------------------------------------------------------------------
  Future<void> _initializeWeb(FrameCallbackWeb onFrame) async {
    // Create a hidden video element used as the camera source
    _webVideo = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.width = "0px"
      ..style.height = "0px";

    html.document.body!.append(_webVideo!);

    // Request user media (camera)
    final stream = await html.window.navigator.mediaDevices!.getUserMedia({
      "video": {
        "facingMode": "user",
      }
    });

    _webVideo!.srcObject = stream;

    // Wait for metadata to be loaded so that videoWidth/videoHeight are valid
    final completer = Completer<void>();
    _webVideo!.onLoadedMetadata.listen((event) {
      completer.complete();
    });

    await _webVideo!.play();
    await completer.future;

    // Now we can safely read videoWidth / videoHeight
    final int vw = _webVideo!.videoWidth;
    final int vh = _webVideo!.videoHeight;

    if (vw == 0 || vh == 0) {
      // Fallback: mark as not ready and do not start timer
      _webReady = false;
      return;
    }

    _webCanvas = html.CanvasElement(width: vw, height: vh);
    _webCtx = _webCanvas!.getContext("2d") as html.CanvasRenderingContext2D;

    _webReady = true;

    // Periodic frame extraction (~30 FPS)
    _webFrameTimer = Timer.periodic(
      const Duration(milliseconds: 33),
      (_) {
        if (!_webReady ||
            _webVideo == null ||
            _webVideo!.videoWidth == 0 ||
            _webVideo!.videoHeight == 0) {
          return;
        }

        final w = _webVideo!.videoWidth;
        final h = _webVideo!.videoHeight;

        _webCanvas!
          ..width = w
          ..height = h;

        _webCtx!.drawImage(_webVideo!, 0, 0);

        final imageData = _webCtx!.getImageData(0, 0, w, h);

        onFrame(
          imageData.data!, // Uint8ClampedList
          w,
          h,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------
  void dispose() {
    if (kIsWeb) {
      _webFrameTimer?.cancel();
      _webFrameTimer = null;

      if (_webVideo != null) {
        _webVideo!.srcObject = null;
        _webVideo!.remove();
        _webVideo = null;
      }

      _webCanvas = null;
      _webCtx = null;
      _webReady = false;
      return;
    }

    _controller?.dispose();
    _controller = null;
  }
}

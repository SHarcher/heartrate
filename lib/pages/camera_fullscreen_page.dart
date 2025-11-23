import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:camera/camera.dart';

class CameraFullscreenPage extends StatefulWidget {
  final CameraController? controller;
  final VoidCallback onMinimize;

  const CameraFullscreenPage({
    super.key,
    required this.controller,
    required this.onMinimize,
  });

  @override
  State<CameraFullscreenPage> createState() => _CameraFullscreenPageState();
}

class _CameraFullscreenPageState extends State<CameraFullscreenPage> {
  html.VideoElement? _video;
  late final String _viewId;

  @override
  void initState() {
    super.initState();

    _viewId = "fullscreen-web-${DateTime.now().millisecondsSinceEpoch}";

    if (kIsWeb) {
      _initWebPreview();
    }
  }

  void _initWebPreview() {
    _video = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.objectFit = "cover";

    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _video!,
    );

    final existing = html.document.querySelector("video");
    if (existing != null && existing is html.VideoElement) {
      _video!.srcObject = existing.srcObject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.minimize, color: Colors.white),
          onPressed: widget.onMinimize,
        ),
        elevation: 0,
        title: const Text("Camera Preview"),
      ),
      body: Center(
        child: kIsWeb
            ? HtmlElementView(viewType: _viewId)
            : (controller != null && controller.value.isInitialized)
                ? CameraPreview(controller)
                : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

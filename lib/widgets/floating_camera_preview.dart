import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:camera/camera.dart';

class FloatingCameraPreview extends StatefulWidget {
  final CameraController? controller;
  final VoidCallback onTap;

  const FloatingCameraPreview({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  State<FloatingCameraPreview> createState() => _FloatingCameraPreviewState();
}

class _FloatingCameraPreviewState extends State<FloatingCameraPreview> {
  html.VideoElement? _video;
  late final String _viewId;

  @override
  void initState() {
    super.initState();

    _viewId = "floating-web-preview-${DateTime.now().millisecondsSinceEpoch}";

    if (kIsWeb) {
      _initWebPreview();
    }
  }

  Future<void> _initWebPreview() async {
    _video = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.objectFit = "cover"
      ..style.borderRadius = "16px";

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
    return GestureDetector(
      onTap: widget.onTap,
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
        child: kIsWeb
            ? HtmlElementView(viewType: _viewId)
            : (widget.controller != null &&
                    widget.controller!.value.isInitialized)
                ? CameraPreview(widget.controller!)
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
      ),
    );
  }
}

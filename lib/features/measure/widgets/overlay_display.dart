import 'package:flutter/material.dart';

class OverlayDisplay extends StatelessWidget {
  final double? bpm;
  final double? resp;
  const OverlayDisplay({super.key, this.bpm, this.resp});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent),
              const SizedBox(width: 6),
              Text(
                bpm != null ? '${bpm!.toStringAsFixed(1)} bpm' : '--',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.air, color: Colors.cyanAccent),
              const SizedBox(width: 6),
              Text(
                resp != null ? '${resp!.toStringAsFixed(1)} rpm' : '--',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

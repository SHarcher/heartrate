import 'package:flutter/material.dart';

class HeartRateCard extends StatelessWidget {
  final double? bpm;
  final double? quality;

  const HeartRateCard({
    super.key,
    this.bpm,
    this.quality,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            bpm == null ? "-- bpm" : "${bpm!.round()} bpm",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            quality == null
                ? "Signal Quality: --"
                : "Signal Quality: ${(quality! * 100).toStringAsFixed(1)}%",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

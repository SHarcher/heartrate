import 'chrom_algorithm.dart';

typedef HeartRateUpdateCallback = void Function(
  double bpm,
  double quality,
);

class HeartRateEngine {
  final int maxBufferSeconds;
  final int minWindowSeconds;
  final Duration computeInterval;
  final HeartRateUpdateCallback? onUpdate;

  final ChromAlgorithm _alg = const ChromAlgorithm();

  final List<double> _r = [];
  final List<double> _g = [];
  final List<double> _b = [];
  final List<DateTime> _t = [];

  DateTime? _lastCompute;
  double? currentBpm;
  double? currentQuality;

  HeartRateEngine({
    this.maxBufferSeconds = 20,
    this.minWindowSeconds = 8,
    this.computeInterval = const Duration(seconds: 1),
    this.onUpdate,
  });

  /// Add new RGB frame sample
  void addSample(double r, double g, double b, DateTime ts) {
    _r.add(r);
    _g.add(g);
    _b.add(b);
    _t.add(ts);

    _trimOld();

    if (_lastCompute == null ||
        ts.difference(_lastCompute!) >= computeInterval) {
      _lastCompute = ts;
      _computeIfReady();
    }
  }

  /// Remove old samples beyond the buffer limit
  void _trimOld() {
    if (_t.isEmpty) return;

    final latest = _t.last;
    final maxAge = Duration(seconds: maxBufferSeconds);

    while (_t.isNotEmpty && latest.difference(_t.first) > maxAge) {
      _t.removeAt(0);
      _r.removeAt(0);
      _g.removeAt(0);
      _b.removeAt(0);
    }
  }

  /// Compute BPM if enough data is available
  void _computeIfReady() {
    if (_t.length < 30) return;

    final windowSec = _t.last.difference(_t.first).inMilliseconds / 1000.0;

    if (windowSec < minWindowSeconds) return;

    final result = _alg.estimateBpm(_r, _g, _b, _t);

    if (result.bpm != null) {
      currentBpm = result.bpm;
      currentQuality = result.quality;

      if (onUpdate != null) {
        onUpdate!(currentBpm!, currentQuality!);
      }
    }
  }

  /// Reset all buffer and state
  void reset() {
    _r.clear();
    _g.clear();
    _b.clear();
    _t.clear();
    currentBpm = null;
    currentQuality = null;
    _lastCompute = null;
  }
}

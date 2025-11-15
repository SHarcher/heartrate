import 'dart:math';

class ChromResult {
  final double? bpm;
  final double? quality;

  const ChromResult({this.bpm, this.quality});
}

class ChromAlgorithm {
  final double fMin;
  final double fMax;
  final int numFreqs;

  const ChromAlgorithm({
    this.fMin = 0.7,
    this.fMax = 3.0,
    this.numFreqs = 120,
  });

  ChromResult estimateBpm(
    List<double> r,
    List<double> g,
    List<double> b,
    List<DateTime> t,
  ) {
    final int n = r.length;
    if (n < 30) return const ChromResult();

    final double windowSec = t.last.difference(t.first).inMilliseconds / 1000.0;
    if (windowSec <= 0) return const ChromResult();

    final double dt = windowSec / (n - 1);

    // Remove mean
    final double mr = _mean(r);
    final double mg = _mean(g);
    final double mb = _mean(b);

    final List<double> rr = List.generate(n, (i) => r[i] - mr);
    final List<double> gg = List.generate(n, (i) => g[i] - mg);
    final List<double> bb = List.generate(n, (i) => b[i] - mb);

    // CHROM projection
    final List<double> x = List.generate(n, (i) => 3 * rr[i] - 2 * gg[i]);
    final List<double> y =
        List.generate(n, (i) => 1.5 * rr[i] + gg[i] - 1.5 * bb[i]);

    final double stdX = _std(x);
    final double stdY = _std(y);
    if (stdX < 1e-6 || stdY < 1e-6) return const ChromResult();

    final double alpha = stdX / stdY;
    final List<double> s = List.generate(n, (i) => x[i] - alpha * y[i]);

    final List<double> windowed = _hann(s);

    // Frequency scan
    double bestFreq = 0, bestPower = 0, totalPower = 0;

    for (int k = 0; k < numFreqs; k++) {
      final double f = fMin + (fMax - fMin) * k / (numFreqs - 1);

      double re = 0, im = 0;

      for (int i = 0; i < n; i++) {
        final double ang = 2 * pi * f * (i * dt);
        re += windowed[i] * cos(ang);
        im -= windowed[i] * sin(ang);
      }

      final double p = re * re + im * im;
      totalPower += p;

      if (p > bestPower) {
        bestPower = p;
        bestFreq = f;
      }
    }

    if (bestFreq <= 0) return const ChromResult();

    final bpm = bestFreq * 60;
    if (bpm < 40 || bpm > 200) return const ChromResult();

    final quality = bestPower / totalPower;

    return ChromResult(bpm: bpm, quality: quality);
  }

  double _mean(List<double> x) => x.reduce((a, b) => a + b) / x.length;

  double _std(List<double> x) {
    final m = _mean(x);
    double v = 0;
    for (var e in x) {
      v += (e - m) * (e - m);
    }
    return sqrt(v / x.length);
  }

  List<double> _hann(List<double> x) {
    final n = x.length;
    return List.generate(
      n,
      (i) => x[i] * (0.5 * (1 - cos(2 * pi * i / (n - 1)))),
    );
  }
}

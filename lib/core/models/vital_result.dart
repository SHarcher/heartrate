class VitalResult {
  final double? heartRate;
  final double? respiration;
  VitalResult({this.heartRate, this.respiration});

  factory VitalResult.fromJson(Map<String, dynamic> json) {
    return VitalResult(
      heartRate: json['heart_rate']?['value']?.toDouble(),
      respiration: json['respiratory_rate']?['value']?.toDouble(),
    );
  }
}

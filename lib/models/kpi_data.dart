class KpiData {
  final int total;
  final int pending;
  final int started;
  final int finished;
  final int problems;
  final int slaRespected;
  final int slaNotRespected;
  final double sla;
  final int avgTime;
  final int avgDelay;
  final List<dynamic> byActel;

  KpiData({
    required this.total,
    required this.pending,
    required this.started,
    required this.finished,
    required this.problems,
    required this.slaRespected,
    required this.slaNotRespected,
    required this.sla,
    required this.avgTime,
    required this.avgDelay,
    required this.byActel,
  });

  factory KpiData.fromJson(Map<String, dynamic> json) {
    return KpiData(
      total: _toInt(json['total']),
      pending: _toInt(json['pending']),
      started: _toInt(json['started']),
      finished: _toInt(json['finished']),
      problems: _toInt(json['problems']),
      slaRespected: _toInt(json['sla_respected']),
      slaNotRespected: _toInt(json['sla_not_respected']),
      sla: _toDouble(json['sla']),
      avgTime: _toInt(json['avg_time']),
      avgDelay: _toInt(json['avg_delay']),
      byActel: json['by_actel'] is List ? json['by_actel'] : [],
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
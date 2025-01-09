class SgvResponse {
  final String id;
  final String device;
  final String dateString;
  final DateTime sysTime;
  final int date;
  final int sgv;
  final double delta;
  final String direction;
  final int noise;
  final int filtered;
  final int unfiltered;
  final int rssi;
  final String type;
  final String? unitsHint;

  SgvResponse({
    required this.id,
    required this.device,
    required this.dateString,
    required this.sysTime,
    required this.date,
    required this.sgv,
    required this.delta,
    required this.direction,
    required this.noise,
    required this.filtered,
    required this.unfiltered,
    required this.rssi,
    required this.type,
    this.unitsHint,
  });

  factory SgvResponse.fromJson(Map<String, dynamic> json) {
    return SgvResponse(
      id: json['_id'],
      device: json['device'],
      dateString: json['dateString'],
      sysTime: DateTime.parse(json['sysTime']),
      date: json['date'],
      sgv: json['sgv'],
      delta: json['delta'].toDouble(),
      direction: json['direction'],
      noise: json['noise'].toInt(),
      filtered: json['filtered'].toInt(),
      unfiltered: json['unfiltered'].toInt(),
      rssi: json['rssi'].toInt(),
      type: json['type'],
      unitsHint: json['units_hint'],
    );
  }
}
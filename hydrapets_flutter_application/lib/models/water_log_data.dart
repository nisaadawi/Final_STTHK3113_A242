class WaterLogData {
  final int waterId;
  final int waterLevel;
  final String waterStatus;
  final int waterPercentage;
  final String relayStatus;
  final String timestamp;

  WaterLogData({
    required this.waterId,
    required this.waterLevel,
    required this.waterStatus,
    required this.waterPercentage,
    required this.relayStatus,
    required this.timestamp,
  });

  factory WaterLogData.fromJson(Map<String, dynamic> json) {
    return WaterLogData(
      waterId: int.parse(json['water_id'].toString()),
      waterLevel: int.parse(json['water_level'].toString()),
      waterStatus: json['water_status'] ?? '',
      waterPercentage: int.parse(json['water_percentage'].toString()),
      relayStatus: json['relay_status'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}


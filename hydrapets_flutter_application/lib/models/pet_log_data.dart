import 'package:intl/intl.dart';

class PetLogData {
  final int petId;
  final String petStatus;
  final String ledStatus;
  final DateTime timestamp;

  PetLogData({
    required this.petId,
    required this.petStatus,
    required this.ledStatus,
    required this.timestamp,
  });

  factory PetLogData.fromJson(Map<String, dynamic> json) {
    return PetLogData(
      petId: int.parse(json['pet_id'].toString()),
      petStatus: json['pet_status'] as String,
      ledStatus: json['led_status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get formattedTime => DateFormat('HH:mm').format(timestamp);
  String get formattedDate => DateFormat('d MMMM yyyy').format(timestamp);
}

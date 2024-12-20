import 'package:get/get.dart';

class LocalUpdate {
  final String farm;
  final String lot;
  final String team;
  final String row;
  final Map<String, int> statusCounts;
  final String tapAge;
  final DateTime updateTime;

  LocalUpdate({
    required this.farm,
    required this.lot,
    required this.team,
    required this.row,
    required this.statusCounts,
    required this.tapAge,
    required this.updateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'farm': farm,
      'lot': lot,
      'team': team,
      'row': row,
      'statusCounts': statusCounts,
      'tapAge': tapAge,
      'updateTime': updateTime.toIso8601String(),
    };
  }

  factory LocalUpdate.fromJson(Map<String, dynamic> json) {
    return LocalUpdate(
      farm: json['farm'] as String,
      lot: json['lot'] as String,
      team: json['team'] as String,
      row: json['row'] as String,
      statusCounts: Map<String, int>.from(json['statusCounts'] as Map),
      tapAge: json['tapAge'] as String,
      updateTime: DateTime.parse(json['updateTime'] as String),
    );
  }
}

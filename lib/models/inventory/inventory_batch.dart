import 'package:json_annotation/json_annotation.dart';

part 'inventory_batch.g.dart';

@JsonSerializable()
class InventoryBatch {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'startDate')
  final DateTime startDate;

  @JsonKey(name: 'endDate')
  final DateTime endDate;

  @JsonKey(name: 'isCompleted')
  final bool isCompleted;

  @JsonKey(name: 'description')
  final String? description;

  InventoryBatch({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isCompleted,
    this.description,
  });

  factory InventoryBatch.fromJson(Map<String, dynamic> json) => _$InventoryBatchFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryBatchToJson(this);
}

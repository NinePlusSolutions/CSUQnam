import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_getx_boilerplate/models/local/shaved_status_update.dart';

part 'local_tree_update.g.dart';

@JsonSerializable()
class LocalTreeUpdate {
  @JsonKey(name: 'farmId')
  final int farmId;
  @JsonKey(name: 'farmName')
  final String farmName;
  @JsonKey(name: 'productTeamId')
  final int productTeamId;
  @JsonKey(name: 'productTeamName')
  final String productTeamName;
  @JsonKey(name: 'farmLotId')
  final int farmLotId;
  @JsonKey(name: 'farmLotName')
  final String farmLotName;
  @JsonKey(name: 'treeLineName')
  final String treeLineName;
  @JsonKey(name: 'shavedStatus')
  final int shavedStatusId;
  @JsonKey(name: 'shavedStatusName')
  final String shavedStatusName;
  @JsonKey(name: 'dateCheck')
  final DateTime dateCheck;
  @JsonKey(name: 'statusUpdates')
  final List<LocalStatusUpdate> statusUpdates;
  @JsonKey(name: 'note')
  final String? note;

  LocalTreeUpdate({
    required this.farmId,
    required this.farmName,
    required this.productTeamId,
    required this.productTeamName,
    required this.farmLotId,
    required this.farmLotName,
    required this.treeLineName,
    required this.shavedStatusId,
    required this.shavedStatusName,
    required this.dateCheck,
    required this.statusUpdates,
    this.note,
  });

  factory LocalTreeUpdate.fromJson(Map<String, dynamic> json) =>
      _$LocalTreeUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$LocalTreeUpdateToJson(this);
}

@JsonSerializable()
class LocalStatusUpdate {
  @JsonKey(name: 'statusId')
  final int statusId;
  @JsonKey(name: 'statusName')
  final String statusName;
  @JsonKey(name: 'value')
  final String value;

  LocalStatusUpdate({
    required this.statusId,
    required this.statusName,
    required this.value,
  });

  factory LocalStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$LocalStatusUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$LocalStatusUpdateToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'shaved_status_update.g.dart';

@JsonSerializable()
class ShavedStatusUpdate {
  final int id;
  final String name;
  final int? parentId;

  ShavedStatusUpdate({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory ShavedStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$ShavedStatusUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$ShavedStatusUpdateToJson(this);
}

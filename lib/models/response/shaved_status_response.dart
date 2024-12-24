import 'package:json_annotation/json_annotation.dart';

part 'shaved_status_response.g.dart';

@JsonSerializable()
class ShavedStatusResponse {
  final ShavedStatusData data;
  final List<String> messages;
  final bool status;

  ShavedStatusResponse({
    required this.data,
    required this.messages,
    required this.status,
  });

  factory ShavedStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ShavedStatusResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ShavedStatusResponseToJson(this);
}

@JsonSerializable()
class ShavedStatusData {
  @JsonKey(name: 'BO1')
  final List<ShavedStatusItem> bo1;
  @JsonKey(name: 'BO2')
  final List<ShavedStatusItem> bo2;
  @JsonKey(name: 'HO')
  final List<ShavedStatusItem> ho;
  @JsonKey(name: 'TT')
  final List<ShavedStatusItem> tt;

  ShavedStatusData({
    required this.bo1,
    required this.bo2,
    required this.ho,
    required this.tt,
  });

  factory ShavedStatusData.fromJson(Map<String, dynamic> json) =>
      _$ShavedStatusDataFromJson(json);
  Map<String, dynamic> toJson() => _$ShavedStatusDataToJson(this);
}

@JsonSerializable()
class ShavedStatusItem {
  final int id;
  final String name;
  final String? description;
  final int? parentId;

  ShavedStatusItem({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
  });

  factory ShavedStatusItem.fromJson(Map<String, dynamic> json) =>
      _$ShavedStatusItemFromJson(json);
  Map<String, dynamic> toJson() => _$ShavedStatusItemToJson(this);
}

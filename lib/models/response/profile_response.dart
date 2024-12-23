class ProfileResponse {
  final Data? data;
  final List<dynamic> messages;
  final bool status;

  ProfileResponse({
    this.data,
    required this.messages,
    required this.status,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) => ProfileResponse(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        messages: List<dynamic>.from(json["messages"] ?? []),
        status: json["status"] ?? false,
      );
}

class Data {
  final String id;
  final String email;
  final String phoneNumber;
  final String fullName;
  final dynamic avatarUrl;
  final bool isActive;
  final dynamic address;
  final dynamic status;
  final dynamic dateOfBirth;
  final List<FarmByUserResponse> farmByUserResponse;

  Data({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    this.avatarUrl,
    required this.isActive,
    this.address,
    this.status,
    this.dateOfBirth,
    required this.farmByUserResponse,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] ?? "",
        email: json["email"] ?? "",
        phoneNumber: json["phoneNumber"] ?? "",
        fullName: json["fullName"] ?? "",
        avatarUrl: json["avatarUrl"],
        isActive: json["isActive"] ?? false,
        address: json["address"],
        status: json["status"],
        dateOfBirth: json["dateOfBirth"],
        farmByUserResponse: List<FarmByUserResponse>.from(
            (json["farmByUserResponse"] ?? [])
                .map((x) => FarmByUserResponse.fromJson(x))),
      );
}

class FarmByUserResponse {
  final int farmId;
  final int productTeamId;
  final int farmLotId;
  final dynamic ageShaved;
  final String userId;
  final String farmName;
  final String farmLotName;
  final String productTeamName;
  final List<TreeLineByFarmLotResponse> treeLineByFarmLotResponse;

  FarmByUserResponse({
    required this.farmId,
    required this.productTeamId,
    required this.farmLotId,
    this.ageShaved,
    required this.userId,
    required this.farmName,
    required this.farmLotName,
    required this.productTeamName,
    required this.treeLineByFarmLotResponse,
  });

  factory FarmByUserResponse.fromJson(Map<String, dynamic> json) =>
      FarmByUserResponse(
        farmId: json["farmId"] ?? 0,
        productTeamId: json["productTeamId"] ?? 0,
        farmLotId: json["farmLotId"] ?? 0,
        ageShaved: json["ageShaved"],
        userId: json["userId"] ?? "",
        farmName: json["farmName"] ?? "",
        farmLotName: json["farmLotName"] ?? "",
        productTeamName: json["productTeamName"] ?? "",
        treeLineByFarmLotResponse: List<TreeLineByFarmLotResponse>.from(
            (json["treeLineByFarmLotResponse"] ?? [])
                .map((x) => TreeLineByFarmLotResponse.fromJson(x))),
      );
}

class TreeLineByFarmLotResponse {
  final int id;
  final String name;
  final int rowNumber;

  TreeLineByFarmLotResponse({
    required this.id,
    required this.name,
    required this.rowNumber,
  });

  factory TreeLineByFarmLotResponse.fromJson(Map<String, dynamic> json) =>
      TreeLineByFarmLotResponse(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        rowNumber: json["rowNumber"] ?? 0,
      );
}

class StatusResponse {
  final List<StatusItem> data;

  StatusResponse({
    required this.data,
  });

  factory StatusResponse.fromJson(Map<String, dynamic> json) {
    return StatusResponse(
      data: (json['data'] as List)
          .map((item) => StatusItem.fromJson(item))
          .toList(),
    );
  }
}

class StatusItem {
  final int id;
  final String name;
  final String description;
  final String value;

  StatusItem({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
  });

  factory StatusItem.fromJson(Map<String, dynamic> json) {
    return StatusItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      value: json['value'] as String? ?? json['name'] as String, // Nếu không có value thì dùng name
    );
  }
}

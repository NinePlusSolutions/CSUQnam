class InventoryBatch {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final String description;

  InventoryBatch({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isCompleted,
    required this.description,
  });

  factory InventoryBatch.fromJson(Map<String, dynamic> json) {
    return InventoryBatch(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isCompleted: json['isCompleted'],
      description: json['description'],
    );
  }
}

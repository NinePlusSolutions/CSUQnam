class InventorySection {
  final String farm;
  final String lot;
  final String team;
  final String row;
  final Map<String, int> statusCounts;

  InventorySection({
    required this.farm,
    required this.lot,
    required this.team,
    required this.row,
    required this.statusCounts,
  });

  String get key => '$farm-$lot-$team-$row';

  Map<String, dynamic> toMap() {
    return {
      'farm': farm,
      'lot': lot,
      'team': team,
      'row': row,
      'statusCounts': statusCounts,
    };
  }

  factory InventorySection.fromMap(Map<String, dynamic> map) {
    return InventorySection(
      farm: map['farm'] as String,
      lot: map['lot'] as String,
      team: map['team'] as String,
      row: map['row'] as String,
      statusCounts: Map<String, int>.from(map['statusCounts'] as Map),
    );
  }

  InventorySection copyWith({
    String? farm,
    String? lot,
    String? team,
    String? row,
    Map<String, int>? statusCounts,
  }) {
    return InventorySection(
      farm: farm ?? this.farm,
      lot: lot ?? this.lot,
      team: team ?? this.team,
      row: row ?? this.row,
      statusCounts: statusCounts ?? this.statusCounts,
    );
  }
}

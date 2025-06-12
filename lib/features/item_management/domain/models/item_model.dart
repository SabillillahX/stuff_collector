class Item {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.createdAt,
  });

  Item copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Item {
  final String id;
  final String name;
  final String code;
  final String category;
  final int quantity;
  final double price;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  Item copyWith({
    String? id,
    String? name,
    String? code,
    String? category,
    int? quantity,
    double? price,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'category': category,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      category: json['category'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

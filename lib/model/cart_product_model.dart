class CartProductModel {
  final int id;
  final String name;
  final String image;
  final String description;
  final int bengkelId;
  final int price;
  final int weight;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.bengkelId,
    required this.price,
    required this.weight,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    return CartProductModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      bengkelId: json['bengkel_id'],
      price: json['price'],
      weight: json['weight'],
      stock: json['stock'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'bengkel_id': bengkelId,
      'price': price,
      'weight': weight,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

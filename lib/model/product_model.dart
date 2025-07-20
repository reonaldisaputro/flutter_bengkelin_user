import 'package:flutter_bengkelin_user/model/bengkel_model.dart';

class ProductModel {
  final int id;
  final String name;
  final String image;
  final String description;
  final int bengkelId;
  final int price;
  final int weight;
  final int stock;
  final String createdAt;
  final String updatedAt;
  final BengkelModel bengkel;

  ProductModel({
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
    required this.bengkel,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      bengkelId: json['bengkel_id'] ?? 0,
      price: json['price'] ?? 0,
      weight: json['weight'] ?? 0,
      stock: json['stock'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      bengkel: BengkelModel.fromJson(json['bengkel'] ?? {}),
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
      'created_at': createdAt,
      'updated_at': updatedAt,
      'bengkel': bengkel.toJson(),
    };
  }
}
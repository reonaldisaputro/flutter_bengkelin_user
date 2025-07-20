import 'bengkel_model.dart';
import 'cart_product_model.dart';

class CartModel {
  final int id;
  final int bengkelId;
  final int productId;
  final int userId;
  int quantity;
  final int price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CartProductModel product;
  final BengkelModel bengkel;

  CartModel({
    required this.id,
    required this.bengkelId,
    required this.productId,
    required this.userId,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
    required this.bengkel,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      bengkelId: json['bengkel_id'],
      productId: json['product_id'],
      userId: json['user_id'],
      quantity: json['quantity'],
      price: json['price'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      product: CartProductModel.fromJson(json['product']),
      bengkel: BengkelModel.fromJson(json['bengkel']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bengkel_id': bengkelId,
      'product_id': productId,
      'user_id': userId,
      'quantity': quantity,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'product': product.toJson(),
      'bengkel': bengkel.toJson(),
    };
  }
}

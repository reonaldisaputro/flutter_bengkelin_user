import 'product_model.dart'; // Sesuaikan import ini

class ProductListResponse {
  final int currentPage;
  final List<ProductModel> products;

  ProductListResponse({
    required this.currentPage,
    required this.products,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      currentPage: json['current_page'] ?? 1,
      products: List<ProductModel>.from(
        (json['data'] as List<dynamic>).map((e) => ProductModel.fromJson(e)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': products.map((e) => e.toJson()).toList(),
    };
  }
}

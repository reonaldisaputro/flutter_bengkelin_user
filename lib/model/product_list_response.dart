import 'product_model.dart'; // Sesuaikan import ini

class ProductListResponse {
  final int currentPage;
  final int lastPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final List<ProductModel> products;

  ProductListResponse({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
    required this.products,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      products: List<ProductModel>.from(
        (json['data'] as List<dynamic>).map((e) => ProductModel.fromJson(e)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'total': total,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
      'data': products.map((e) => e.toJson()).toList(),
    };
  }
}

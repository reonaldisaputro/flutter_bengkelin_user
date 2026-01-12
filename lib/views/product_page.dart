import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/views/product_detail_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../model/product_model.dart';
import '../../viewmodel/product_viewmodel.dart';
import '../../widget/custom_toast.dart';
import '../model/product_list_response.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> filteredProducts = [];
  List<ProductModel> _products = [];

  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    getProducts();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // TODO: Implement search functionality
    // final query = _searchController.text.toLowerCase();
    setState(() {
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _lastPage) {
      _loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      appBar: AppBar(
        title: const Text(
          'Product',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or shop',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Product Grid
          Expanded(
            child: _isInitialLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      controller: _scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.7,
                      ),
                      itemCount:
                          _products.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _products.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final product = _products[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailPage(productId: product.id),
                              ),
                            );
                          },
                          child: _buildProductCard(product),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                '${dotenv.env["IMAGE_BASE_URL"]}/${product.image}',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.bengkel.name,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${product.price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  getProducts() async {
    setState(() {
      _isInitialLoading = true;
    });

    try {
      await ProductViewmodel().products(page: 1).then((value) {
        print('Full Response Code: ${value.code}'); // Debug
        print('Full Response Data Type: ${value.data.runtimeType}'); // Debug

        if (value.code == 200) {
          // value.data sudah berisi object pagination dari Laravel
          final responseData = value.data;
          print('Response Data Keys: ${responseData.keys}'); // Debug
          print('Current Page: ${responseData['current_page']}'); // Debug
          print('Last Page: ${responseData['last_page']}'); // Debug
          print('Products Count: ${(responseData['data'] as List).length}'); // Debug

          final productList = ProductListResponse.fromJson(responseData);
          print('Products loaded: ${productList.products.length}'); // Debug

          setState(() {
            _products = productList.products;
            _currentPage = productList.currentPage;
            _lastPage = productList.lastPage;
            _isInitialLoading = false;
          });
          print('State updated - isLoading: $_isInitialLoading'); // Debug
        } else {
          print('Response code not 200: ${value.code}'); // Debug
          setState(() {
            _isInitialLoading = false;
          });
          if (!mounted) return;
          showToast(context: context, msg: value.message);
        }
      });
    } catch (e, stackTrace) {
      print('Error loading products: $e'); // Debug
      print('Stack trace: $stackTrace'); // Debug
      setState(() {
        _isInitialLoading = false;
      });
      if (!mounted) return;
      showToast(context: context, msg: 'Error: $e');
    }
  }

  _loadMoreProducts() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;

    await ProductViewmodel().products(page: nextPage).then((value) {
      if (value.code == 200) {
        final responseData = value.data;
        final productList = ProductListResponse.fromJson(responseData);
        setState(() {
          _products.addAll(productList.products);
          _currentPage = productList.currentPage;
          _lastPage = productList.lastPage;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
        if (!mounted) return;
        showToast(context: context, msg: value.message);
      }
    });
  }

}

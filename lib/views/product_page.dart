import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/views/product_detail_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/category_model.dart';
import '../model/product_model.dart';
import '../model/product_list_response.dart';
import '../viewmodel/category_viewmodel.dart';
import '../viewmodel/product_viewmodel.dart';
import '../widget/custom_toast.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];

  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;
  bool _isLoadingCategories = true;

  int? _selectedCategoryId;
  String _searchKeyword = '';
  Timer? _debounce;

  // Price filter
  int? _minPrice;
  int? _maxPrice;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('=== ProductPage initState called ===');
    _getCategories();
    _getProducts();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.length >= 3 || query.isEmpty) {
        setState(() {
          _searchKeyword = query.length >= 3 ? query : '';
          _currentPage = 1;
          _products.clear();
        });
        _getProducts();
      }
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
          // Search Bar with Filter Button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search product (min 3 characters)',
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
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: (_minPrice != null || _maxPrice != null)
                        ? const Color(0xFF1A1A2E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _showPriceFilterBottomSheet,
                    icon: Icon(
                      Icons.filter_list,
                      color: (_minPrice != null || _maxPrice != null)
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Category Filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: const Text('Semua'),
                      selected: _selectedCategoryId == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategoryId = null;
                            _currentPage = 1;
                            _products.clear();
                          });
                          _getProducts();
                        }
                      },
                      selectedColor: const Color(0xFF1A1A2E),
                      labelStyle: TextStyle(
                        color: _selectedCategoryId == null
                            ? Colors.white
                            : Colors.black,
                      ),
                      backgroundColor: Colors.white,
                    ),
                  );
                }

                final category = _categories[index - 1];
                final isSelected = _selectedCategoryId == category.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = selected ? category.id : null;
                        _currentPage = 1;
                        _products.clear();
                      });
                      _getProducts();
                    },
                    selectedColor: const Color(0xFF1A1A2E),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    backgroundColor: Colors.white,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),

          // Product Grid
          Expanded(
            child: _isInitialLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Platform.isAndroid
                        ? RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: _buildProductGrid(),
                          )
                        : _buildProductGrid(),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    _lastPage = 1;
    _products.clear();
    await _getProducts();
  }

  void _showPriceFilterBottomSheet() {
    _minPriceController.text = _minPrice?.toString() ?? '';
    _maxPriceController.text = _maxPrice?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Harga',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga Min',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga Max',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _minPriceController.clear();
                        _maxPriceController.clear();
                        setState(() {
                          _minPrice = null;
                          _maxPrice = null;
                          _currentPage = 1;
                          _products.clear();
                        });
                        Navigator.pop(context);
                        _getProducts();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final minText = _minPriceController.text.trim();
                        final maxText = _maxPriceController.text.trim();

                        setState(() {
                          _minPrice = minText.isNotEmpty ? int.tryParse(minText) : null;
                          _maxPrice = maxText.isNotEmpty ? int.tryParse(maxText) : null;
                          _currentPage = 1;
                          _products.clear();
                        });
                        Navigator.pop(context);
                        _getProducts();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Terapkan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.7,
      ),
      itemCount: _products.length + (_isLoadingMore ? 1 : 0),
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
                builder: (context) => ProductDetailPage(productId: product.id),
              ),
            );
          },
          child: _buildProductCard(product),
        );
      },
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

  Future<void> _getCategories() async {
    debugPrint('=== _getCategories START ===');
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      debugPrint('Calling CategoryViewmodel().getCategories()...');
      final value = await CategoryViewmodel().getCategories();
      debugPrint('Categories API response code: ${value.code}');
      debugPrint('Categories API response data: ${value.data}');

      if (value.code == 200 && value.data != null) {
        final List<dynamic> data = value.data;
        setState(() {
          _categories = data.map((e) => CategoryModel.fromJson(e)).toList();
          _isLoadingCategories = false;
        });
        debugPrint('Categories loaded: ${_categories.length}');
      } else {
        debugPrint('Categories failed: ${value.message}');
        setState(() {
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      debugPrint('Categories error: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _getProducts() async {
    setState(() {
      _isInitialLoading = true;
    });

    try {
      final value = await ProductViewmodel().products(
        page: 1,
        keyword: _searchKeyword.isNotEmpty ? _searchKeyword : null,
        categoryId: _selectedCategoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );

      if (value.code == 200) {
        final responseData = value.data;
        final productList = ProductListResponse.fromJson(responseData);

        setState(() {
          _products = productList.products;
          _currentPage = productList.currentPage;
          _lastPage = productList.lastPage;
          _isInitialLoading = false;
        });
      } else {
        setState(() {
          _isInitialLoading = false;
        });
        if (!mounted) return;
        showToast(context: context, msg: value.message);
      }
    } catch (e) {
      setState(() {
        _isInitialLoading = false;
      });
      if (!mounted) return;
      showToast(context: context, msg: 'Error: $e');
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;

    try {
      final value = await ProductViewmodel().products(
        page: nextPage,
        keyword: _searchKeyword.isNotEmpty ? _searchKeyword : null,
        categoryId: _selectedCategoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );

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
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }
}

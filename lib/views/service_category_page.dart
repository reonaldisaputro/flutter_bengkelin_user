import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/views/checkout_page.dart';
import 'package:intl/intl.dart'; // Untuk format mata uang

class ServiceCategoryPage extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> categoryServices;

  const ServiceCategoryPage({
    super.key,
    required this.categoryName,
    required this.categoryServices,
  });

  @override
  State<ServiceCategoryPage> createState() => _ServiceCategoryPageState();
}

class _ServiceCategoryPageState extends State<ServiceCategoryPage> {
  final Map<Map<String, dynamic>, int> _selectedServices = {};
  double _totalPrice = 0.0;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _filteredServices = widget.categoryServices;
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _parsePrice(String priceString) {
    String cleanPrice = priceString
        .replaceAll('Rp ', '')
        .replaceAll('.', '')
        .replaceAll(',', '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = widget.categoryServices.where((service) {
        final nameLower = service['name']?.toLowerCase() ?? '';
        final descriptionLower = service['description']?.toLowerCase() ?? '';
        final workshopLower = service['workshop']?.toLowerCase() ?? '';

        return nameLower.contains(query) ||
            descriptionLower.contains(query) ||
            workshopLower.contains(query);
      }).toList();
    });
  }

  void _updateServiceQuantity(Map<String, dynamic> service, int change) {
    setState(() {
      int currentQuantity = _selectedServices[service] ?? 0;
      int newQuantity = currentQuantity + change;

      if (newQuantity > 0) {
        _selectedServices[service] = newQuantity;
      } else {
        _selectedServices.remove(service);
      }
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    double tempTotal = 0.0;
    _selectedServices.forEach((service, quantity) {
      String? priceString = service['price'] as String?;
      if (priceString != null) {
        tempTotal += _parsePrice(priceString) * quantity;
      }
    });
    setState(() {
      _totalPrice = tempTotal;
    });
  }

  String _formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari layanan...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _filteredServices.isEmpty && _searchController.text.isNotEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Layanan tidak ditemukan.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      final int currentQuantity =
                          _selectedServices[service] ?? 0;
                      return _buildServiceGridItem(
                        context,
                        service,
                        currentQuantity,
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: _selectedServices.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Harga:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        _formatCurrency(_totalPrice),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F625D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedServices.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                selectedServices: _selectedServices,
                                totalPrice:
                                    _totalPrice, // Mengirim total harga dari ServiceCategoryPage
                                productToCheckout:
                                    null, // Null karena ini adalah servis, bukan produk
                                selectedService:
                                    null, // Null karena kita mengirim multiple services
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pilih setidaknya satu layanan untuk checkout.',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F625D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Check Out Sekarang',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildServiceGridItem(
    BuildContext context,
    Map<String, dynamic> service,
    int currentQuantity,
  ) {
    final String imageUrl = service['image'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: currentQuantity > 0 ? const Color(0xFFD3E0D6) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: currentQuantity > 0
            ? Border.all(color: const Color(0xFF4F625D), width: 2)
            : null,
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
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.asset(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'] as String? ?? 'Nama Tidak Tersedia',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  _formatCurrency(
                    _parsePrice(service['price'] as String? ?? '0'),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF4F625D),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: currentQuantity > 0
                          ? () => _updateServiceQuantity(service, -1)
                          : null,
                    ),
                    Text(
                      '$currentQuantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF4F625D),
                      ),
                      onPressed: () => _updateServiceQuantity(service, 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; // Pastikan Anda memiliki package ini di pubspec.yaml

class CheckoutPage extends StatefulWidget {
  // Parameter asli yang Anda inginkan dari ProductDetailPage
  final Map<String, dynamic>? productToCheckout;
  final double? totalPrice; // ini akan menjadi initialTotalPrice di constructor
  final Map<String, dynamic>?
  selectedService; // ini bisa jadi product atau service tunggal

  // Parameter dari ServiceCategoryPage
  final Map<Map<String, dynamic>, int>?
  selectedServices; // Untuk multiple services (e.g., General Repair)

  const CheckoutPage({
    super.key,
    this.productToCheckout,
    this.totalPrice, // Ini sekarang nullable dan bisa berasal dari product detail
    this.selectedService, // Ini sekarang nullable dan bisa berasal dari product detail (sebagai single item)
    this.selectedServices, // Ini untuk multiple services dari kategori
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final List<Map<String, dynamic>> _cartItems =
      []; // Daftar semua item di keranjang
  double _currentCalculatedTotalPrice = 0.0;
  double _shippingFee = 10000.0; // Contoh biaya pengiriman
  Map<String, dynamic>? _selectedWorkshop; // Bengkel yang dipilih

  // Contoh data servis tambahan yang bisa dipilih di halaman Checkout
  final List<Map<String, dynamic>> _availableAdditionalServices = [
    {
      'id': 'add_serv_01',
      'name': 'tune Up Mobil',
      'price': 'Rp 55.000',
      'image': 'assets/tune_up.jpg', // Pastikan path gambar ini benar
      'description': 'Pemasangan atau perbaikan spion.',
    },
    {
      'id': 'add_serv_02',
      'name': 'Perbaikan Mesin',
      'price': 'Rp 500.000',
      'image': 'assets/perbaikan_mesin.jpg', // Pastikan path gambar ini benar
      'description': 'Pengisian tekanan ban.',
    },
    {
      'id': 'add_serv_03',
      'name': 'Inspeksi Mobil',
      'price': 'Rp 150.000',
      'image': 'assets/inpeksi_mobil.jpg', // Pastikan path gambar ini benar
      'description': 'Pembersihan menyeluruh bagian dalam mobil.',
    },
  ];

  // Contoh data bengkel
  final List<Map<String, dynamic>> _workshops = [
    {
      'id': 'bengkel_udin',
      'name': 'Bengkel Udin',
      'distance': '100 M',
      'image': 'assets/bengkel1.jpg', // Pastikan path gambar ini benar
      'address': 'Jl. Contoh No. 1, Jakarta',
    },
    {
      'id': 'bengkel_samsul',
      'name': 'Bengkel Samsul',
      'distance': '500 M',
      'image': 'assets/bengkel2.jpg', // Pastikan path gambar ini benar
      'address': 'Jl. Raya No. 10, Jakarta',
    },
    {
      'id': 'bengkel_jaya',
      'name': 'Bengkel Jaya Abadi',
      'distance': '1.2 KM',
      'image': 'assets/bengkel3.jpg', // Pastikan path gambar ini benar
      'address': 'Jl. Mekanik No. 5, Jakarta',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeCartItems();
    _recalculateTotalPrice();
  }

  void _initializeCartItems() {
    _cartItems.clear(); // Pastikan keranjang kosong sebelum diisi ulang

    // PRIORITAS 1: Item dari selectedServices (dari ServiceCategoryPage)
    // Ini akan menjadi "Servis yang Dipilih"
    if (widget.selectedServices != null &&
        widget.selectedServices!.isNotEmpty) {
      widget.selectedServices!.forEach((service, quantity) {
        if (quantity > 0) {
          _cartItems.add({
            ...service,
            'quantity': quantity,
            'id':
                service['id'] ?? UniqueKey().toString(), // Pastikan ada ID unik
            'itemType': 'service_from_category',
          });
        }
      });
    }

    // PRIORITAS 2: Item dari productToCheckout (dari ProductDetailPage)
    // Ini akan menjadi "Produk Utama"
    if (widget.productToCheckout != null &&
        widget.productToCheckout!['name'] != null) {
      // Tambahkan hanya jika belum ada item dengan ID yang sama di _cartItems
      // Ini penting jika productToCheckout juga bisa berasal dari list services
      if (!_cartItems.any(
        (item) => item['id'] == widget.productToCheckout!['id'],
      )) {
        _cartItems.add({
          ...widget.productToCheckout!,
          'quantity': widget.productToCheckout!['quantity'] ?? 1,
          'id': widget.productToCheckout!['id'] ?? UniqueKey().toString(),
          'itemType': 'product_from_detail',
        });
      }
    }
    // PRIORITAS 3: Item dari selectedService (parameter lama, mungkin dari ProductDetailPage)
    // Juga akan menjadi "Produk Utama" jika productToCheckout null
    else if (widget.selectedService != null &&
        widget.selectedService!['name'] != null) {
      if (!_cartItems.any(
        (item) => item['id'] == widget.selectedService!['id'],
      )) {
        _cartItems.add({
          ...widget.selectedService!,
          'quantity': widget.selectedService!['quantity'] ?? 1,
          'id': widget.selectedService!['id'] ?? UniqueKey().toString(),
          'itemType': 'legacy_single_item',
        });
      }
    }
  }

  double _parsePrice(String priceString) {
    String cleanPrice = priceString
        .replaceAll('Rp ', '')
        .replaceAll('.', '')
        .replaceAll(',', '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  void _recalculateTotalPrice() {
    double tempTotal = 0.0;
    for (var item in _cartItems) {
      final itemQuantity = item['quantity'] as int? ?? 1;
      final itemPriceString = item['price'] as String?;

      if (itemPriceString != null) {
        tempTotal += _parsePrice(itemPriceString) * itemQuantity;
      }
    }
    tempTotal += _shippingFee;

    setState(() {
      _currentCalculatedTotalPrice = tempTotal;
    });
  }

  void _updateItemQuantity(Map<String, dynamic> item, int change) {
    setState(() {
      int? currentQuantityInCart;
      int itemIndex = -1;

      // Cari item di _cartItems berdasarkan ID
      for (int i = 0; i < _cartItems.length; i++) {
        if (_cartItems[i]['id'] == item['id']) {
          currentQuantityInCart = _cartItems[i]['quantity'] as int?;
          itemIndex = i;
          break;
        }
      }

      int newQuantity = (currentQuantityInCart ?? 0) + change;

      if (newQuantity <= 0) {
        if (itemIndex != -1) {
          _cartItems.removeAt(itemIndex);
        }
      } else {
        if (itemIndex != -1) {
          _cartItems[itemIndex]['quantity'] = newQuantity;
        } else {
          // Jika item belum ada di _cartItems (misal dari _availableAdditionalServices)
          _cartItems.add({
            ...item,
            'quantity': newQuantity,
            'itemType': 'additional_service_added',
          });
        }
      }
      _recalculateTotalPrice();
    });
  }

  void _deleteItemFromCart(Map<String, dynamic> item) {
    setState(() {
      _cartItems.removeWhere((cartItem) => cartItem['id'] == item['id']);
      _recalculateTotalPrice();
    });
  }

  void _selectWorkshop(Map<String, dynamic> workshop) {
    setState(() {
      _selectedWorkshop = workshop;
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
    final Map<String, dynamic>? displayMainProduct = _cartItems
        .firstWhereOrNull(
          (item) =>
              item['itemType'] == 'product_from_detail' ||
              item['itemType'] == 'legacy_single_item',
        );

    // Servis yang sudah ada di keranjang, tidak termasuk produk utama
    final List<Map<String, dynamic>> displayServices = _cartItems
        .where(
          (item) =>
              item['itemType'] == 'service_from_category' ||
              item['itemType'] == 'additional_service_added',
        )
        .toList();

    // Servis tambahan yang *belum* ada di keranjang untuk ditampilkan di GridView "Servis Tambahan"
    final List<Map<String, dynamic>> servicesToAdd =
        _availableAdditionalServices.where((service) {
          return !_cartItems.any((cartItem) => cartItem['id'] == service['id']);
        }).toList();

    return Scaffold(
      backgroundColor:
          (Colors.grey[100]), // Background lebih terang sesuai gambar
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Produk Utama (Card di paling atas) - Muncul jika ada produk atau service tunggal
            if (displayMainProduct != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        displayMainProduct['image'] ?? 'assets/placeholder.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayMainProduct['name'] as String? ?? 'Produk',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(
                              _parsePrice(
                                displayMainProduct['price'] as String? ??
                                    'Rp 0',
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _deleteItemFromCart(displayMainProduct),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F625D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Bagian Servis yang Dipilih (List View) - untuk servis dari kategori atau yang sudah ditambahkan
            // Diletakkan di atas "Servis Tambahan"
            if (displayServices.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'Servis yang Dipilih', // Judul untuk daftar servis yang sudah ada
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayServices.length,
                      itemBuilder: (context, index) {
                        final serviceItem = displayServices[index];
                        return _buildCartServiceItem(context, serviceItem);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Judul "Servis Tambahan"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Servis Tambahan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            // Bagian Servis Tambahan (Grid View) - untuk menambahkan item
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: servicesToAdd.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Tidak ada servis tambahan yang tersedia atau semua sudah ditambahkan.',
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: servicesToAdd.length,
                      itemBuilder: (context, index) {
                        final service = servicesToAdd[index];
                        return _buildAdditionalServiceCard(context, service);
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // Judul "Pilih Bengkel"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Pilih Bengkel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            // Bagian Pilih Bengkel (Grid View)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.9,
                ),
                itemCount: _workshops.length,
                itemBuilder: (context, index) {
                  final workshop = _workshops[index];
                  return _buildWorkshopCard(context, workshop);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Bagian Total Harga (Bottom Summary)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Text(
                        _formatCurrency(
                          _currentCalculatedTotalPrice - _shippingFee,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shipping Fee:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Text(
                        _formatCurrency(_shippingFee),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1, color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        _formatCurrency(_currentCalculatedTotalPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F625D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _cartItems.isEmpty || _selectedWorkshop == null
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lanjutkan Pembayaran ke ${_selectedWorkshop!['name']}!',
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F625D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Check Out Sekarang',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget untuk Kartu Servis Tambahan (Add Button)
  Widget _buildAdditionalServiceCard(
    BuildContext context,
    Map<String, dynamic> service,
  ) {
    final String imageUrl = service['image'] as String? ?? '';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.asset(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'] as String? ?? 'Nama Servis',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(
                    _parsePrice(service['price'] as String? ?? '0'),
                  ),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _updateItemQuantity(service, 1),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF4F625D),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Tambahkan',
                      style: TextStyle(fontSize: 11, color: Color(0xFF4F625D)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk item servis yang sudah ada di keranjang (dari selectedServices atau tambahan)
  // Ini akan digunakan untuk daftar "Servis yang Dipilih"
  Widget _buildCartServiceItem(
    BuildContext context,
    Map<String, dynamic> serviceItem,
  ) {
    final String imageUrl = serviceItem['image'] as String? ?? '';
    final String serviceName = serviceItem['name'] as String? ?? 'Servis';
    final String servicePrice = serviceItem['price'] as String? ?? 'Rp 0';
    final int serviceQuantity = serviceItem['quantity'] as int? ?? 1;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: imageUrl.isNotEmpty
                  ? Image.asset(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : const SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(_parsePrice(servicePrice)),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4F625D),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    size: 24,
                    color: Colors.red,
                  ),
                  onPressed: () => _updateItemQuantity(serviceItem, -1),
                ),
                Text(
                  '$serviceQuantity',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 24,
                    color: Color(0xFF4F625D),
                  ),
                  onPressed: () => _updateItemQuantity(serviceItem, 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Kartu Bengkel
  Widget _buildWorkshopCard(
    BuildContext context,
    Map<String, dynamic> workshop,
  ) {
    final String imageUrl = workshop['image'] as String? ?? '';
    final bool isSelected = _selectedWorkshop?['id'] == workshop['id'];

    return GestureDetector(
      onTap: () => _selectWorkshop(workshop),
      child: Card(
        elevation: isSelected ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? const BorderSide(color: Color(0xFF4F625D), width: 2)
              : BorderSide.none,
        ),
        color: isSelected ? const Color(0xFFE0F2E9) : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.asset(
                        imageUrl,
                        width: double.infinity,
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
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workshop['name'] as String? ?? 'Nama Bengkel',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workshop['distance'] as String? ?? '0 M'} dari lokasi kamu',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

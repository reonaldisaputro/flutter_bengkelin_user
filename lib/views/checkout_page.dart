import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/viewmodel/checkout_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/payment_webview_page.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = true;
  bool _isProcessingCheckout = false;
  Map<String, dynamic>? _checkoutData;

  @override
  void initState() {
    super.initState();
    getCheckoutSummary();
  }
  
  String _formatCurrency(double amount) {
    final format =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return format.format(amount);
  }
  
  Future<void> getCheckoutSummary() async {
    try {
      final value = await CheckoutViewmodel().getCheckoutSummary();
      if (value.success) {
        setState(() {
          _checkoutData = value.data;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data checkout.")),
        );
      }
    } catch (e) {
      debugPrint("Error fetching checkout data: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> handleCheckout() async {
    if (_checkoutData == null) return;

    setState(() {
      _isProcessingCheckout = true;
    });

    try {
      final costSummary = _checkoutData!['cost_summary'];

      final response = await CheckoutViewmodel().checkout(
        ongkir: (costSummary['shipping_cost'] as num).toDouble(),
        administrasi: (costSummary['admin_fee'] as num).toDouble(),
        grandTotal: (costSummary['grand_total'] as num).toDouble(),
      );

      if (response.code == 200) {
        final paymentUrl = response.data['payment_url'];
        if (paymentUrl != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebViewPage(url: paymentUrl),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? "Gagal memproses checkout.")),
        );
      }
    } catch (e) {
      debugPrint("Error on checkout: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan saat checkout.")),
      );
    } finally {
      setState(() {
        _isProcessingCheckout = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Order')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_checkoutData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Order')),
        body: const Center(child: Text('Gagal memuat data.')),
      );
    }

    final costSummary = _checkoutData!['cost_summary'];
    final double productTotal = (costSummary['sub_total'] as num).toDouble();
    final double shippingCost = (costSummary['shipping_cost'] as num).toDouble();
    final double adminFee = (costSummary['admin_fee'] as num).toDouble();
    final double grandTotal = (costSummary['grand_total'] as num).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Your Order'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1D2A39),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF1D2A39),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductSection(_checkoutData!['order_items'] as List),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Product Total', _formatCurrency(productTotal)),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Ongkos Kirim', _formatCurrency(shippingCost)),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Biaya Admin', _formatCurrency(adminFee)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    'Grand Total',
                    _formatCurrency(grandTotal),
                    isGrandTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessingCheckout ? null : handleCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6B6B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF4A6B6B).withOpacity(0.4),
                ),
                child: _isProcessingCheckout
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ) : const Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildProductRow(
              imageUrl: item['image_url'] ?? 'https://via.placeholder.com/150/e0e0e0?text=No+Image',
              productName: item['product_name'],
              quantity: item['quantity'],
              price: _formatCurrency((item['total_price'] as num).toDouble()),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 20),
        ),
      ],
    );
  }

  Widget _buildProductRow({required String imageUrl, required String productName, required int quantity, required String price}) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'x $quantity',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          price,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2A39),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isGrandTotal = false}) {
    final style = TextStyle(
      fontSize: isGrandTotal ? 18 : 16,
      fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
      color: isGrandTotal ? const Color(0xFF1D2A39) : const Color(0xFF555555),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style),
        Text(value, style: style.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
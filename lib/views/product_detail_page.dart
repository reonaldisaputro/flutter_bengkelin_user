import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/viewmodel/cart_viewmodel.dart';
import 'package:flutter_bengkelin_user/viewmodel/product_viewmodel.dart';
import 'package:flutter_bengkelin_user/viewmodel/rating_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/bengkel_detail_page.dart';
import 'package:flutter_bengkelin_user/views/cart_page.dart';
import 'package:flutter_bengkelin_user/views/checkout_page.dart';
import 'package:flutter_bengkelin_user/widget/custom_toast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../model/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final dynamic productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => ProductDetailPageState();
}

class ProductDetailPageState extends State<ProductDetailPage> {
  final List<Map<String, dynamic>> _reviews = [];
  int _ratingPage = 1;
  int _ratingLastPage = 1;
  int _ratingTotal = 0;
  bool _ratingFirstLoad = true;
  bool _ratingLoadingMore = false;
  bool _ratingRefreshing = false;

  String _formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  ProductModel? _productModel;
  Future<void> getProductId() async {
    final value = await ProductViewmodel().detailProduct(id: widget.productId);
    if (!mounted) return;
    if (value.code == 200) {
      setState(() => _productModel = ProductModel.fromJson(value.data));
    } else {
      showToast(context: context, msg: value.message);
    }
  }

  Future<void> getProductRating({int page = 1, bool append = false}) async {
    if (append) setState(() => _ratingLoadingMore = true);
    if (!append) {
      setState(() {
        _ratingFirstLoad = true;
        _ratingPage = 1;
      });
    }

    final res = await RatingViewmodel().getRatingProduct(
      productId: widget.productId,
      page: page,
    );

    if (!mounted) return;

    if (res.code == 200) {
      final Map<String, dynamic> p = Map<String, dynamic>.from(res.data);
      final List dataList = (p['data'] ?? []) as List;

      setState(() {
        if (!append) _reviews.clear();
        _reviews.addAll(dataList.map((e) => Map<String, dynamic>.from(e)));
        _ratingPage = p['current_page'] ?? page;
        _ratingLastPage = p['last_page'] ?? page;
        _ratingTotal = p['total'] ?? _reviews.length;
        _ratingFirstLoad = false;
        _ratingLoadingMore = false;
        _ratingRefreshing = false;
      });
    } else {
      setState(() {
        _ratingFirstLoad = false;
        _ratingLoadingMore = false;
        _ratingRefreshing = false;
      });
      showToast(context: context, msg: res.message);
    }
  }

  Future<void> _refreshAll() async {
    setState(() => _ratingRefreshing = true);
    await Future.wait([
      getProductId(),
      getProductRating(page: 1, append: false),
    ]);
  }

  void _maybeLoadMore(ScrollNotification sn) {
    if (_ratingLoadingMore || _ratingPage >= _ratingLastPage) return;
    final threshold = 200.0;
    if (sn.metrics.pixels > sn.metrics.maxScrollExtent - threshold) {
      getProductRating(page: _ratingPage + 1, append: true);
    }
  }

  @override
  void initState() {
    super.initState();
    getProductId();
    getProductRating(page: 1, append: false);
  }

  @override
  Widget build(BuildContext context) {
    // final int quantity = 1;
    // final int totalPrice = _productModel?.price ?? 0 * quantity;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _productModel?.name ?? 'Detail Produk',
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _productModel == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
            onRefresh: _refreshAll,
            color: const Color(0xFF4F625D),
            child: NotificationListener<ScrollNotification>(
              onNotification: (sn) {
                _maybeLoadMore(sn);
                return false;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            '${dotenv.env["IMAGE_BASE_URL"]}/${_productModel?.image}',
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _productModel?.name ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _productModel?.bengkel?.name ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _formatCurrency(_productModel?.price ?? 0),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Informasi Bengkel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              if (_productModel?.bengkel.id != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BengkelDetailPage(
                                      bengkelId: _productModel!.bengkel!.id,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${dotenv.env["IMAGE_BASE_URL"]}/${_productModel?.bengkel?.image ?? ""}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  ),
                                ),
                                title: Text(
                                  _productModel?.bengkel.name ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  _productModel?.bengkel?.alamat ?? "",
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _productModel?.description ?? "",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: _ReviewsSection(
                        total: _ratingTotal,
                        firstLoading: _ratingFirstLoad,
                        reviews: _reviews,
                      ),
                    ),

                    if (_ratingLoadingMore) ...[
                      const SizedBox(height: 12),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ] else
                      const SizedBox(height: 24),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            handleAddCart();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F625D),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            'Masukkan Keranjang',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  handleAddCart() async {
    CartViewmodel()
        .addCart(
          bengkelId: _productModel?.bengkel.id,
          productId: _productModel?.id,
        )
        .then((value) {
          if (value.code == 200) {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage()),
            );
          } else {
            if (!mounted) return;
            showToast(context: context, msg: value.message);
          }
        });
  }

  static TextStyle get _h1 => const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: Color(0xFF1A1A2E),
  );
  static TextStyle get _muted =>
      TextStyle(fontSize: 16, color: Colors.grey[600]);
  static TextStyle get _price => const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Color(0xFF1A1A2E),
  );
  static TextStyle get _desc =>
      TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5);
}

String _img(String path) => '${dotenv.env["IMAGE_BASE_URL"]}/$path';

// ---------------- COMPONENTS ----------------

class _ImageHero extends StatelessWidget {
  const _ImageHero({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              height: 250,
              child: Center(
                child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BengkelTile extends StatelessWidget {
  const _BengkelTile({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
  });
  final String title, subtitle, imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({
    required this.total,
    required this.firstLoading,
    required this.reviews,
  });

  final int total;
  final bool firstLoading;
  final List<Map<String, dynamic>> reviews;

  double _avgFromFirstPage() {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<int>(0, (p, e) => p + (e['stars'] as int? ?? 0));
    return sum / reviews.length;
    // catatan: ini rata-rata dari page yg sudah dimuat.
    // kalau mau akurat seluruh total, minta backend kirim avg_rating di product detail.
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & ringkasan
        Row(
          children: [
            Text(
              'Ulasan Pengguna',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            _RatingBadge(avg: _avgFromFirstPage(), total: total),
          ],
        ),
        const SizedBox(height: 12),

        if (firstLoading) ...[
          // skeletons
          for (int i = 0; i < 3; i++) _ReviewSkeleton(),
        ] else if (reviews.isEmpty) ...[
          _EmptyReviews(cs: cs),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ReviewTile(review: reviews[i]),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Menampilkan ${reviews.length} dari $total ulasan',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.avg, required this.total});
  final double avg;
  final int total;

  @override
  Widget build(BuildContext context) {
    final a = avg.isNaN ? 0 : avg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.amber.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '${a.toStringAsFixed(1)} • $total',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final user = Map<String, dynamic>.from(review['user'] ?? {});
    final name = (user['name'] ?? 'User') as String;
    final stars = (review['stars'] ?? 0) as int;
    final createdAt = review['created_at']?.toString();
    final date = createdAt == null
        ? ''
        : DateFormat(
            'dd MMM yyyy',
          ).format(DateTime.parse(createdAt).toLocal());
    final comment = (review['comment'] ?? '') as String;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0x11000000)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header user + stars
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(name: name),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < stars
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 18,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(comment, style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ReviewSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget box({double h = 12, double w = double.infinity}) => Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF3),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0x11000000)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              box(h: 42, w: 42),
              const SizedBox(width: 10),
              Expanded(child: box(w: 120)),
            ],
          ),
          const SizedBox(height: 10),
          box(w: 240),
          const SizedBox(height: 6),
          box(),
          const SizedBox(height: 6),
          box(w: 180),
        ],
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.rate_review_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Belum ada ulasan. Jadilah yang pertama setelah membeli produk ini!',
            ),
          ),
        ],
      ),
    );
  }
}

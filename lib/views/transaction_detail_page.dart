import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'package:flutter_bengkelin_user/viewmodel/transaction_viewmodel.dart';
import 'package:flutter_bengkelin_user/viewmodel/rating_viewmodel.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({super.key, required this.transactionId});
  final int transactionId;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  Map<String, dynamic>? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final resp = await TransactionViewmodel().transactionHistoryDetail(id: widget.transactionId);
    if (!mounted) return;

    if (resp.code == 200) {
      setState(() {
        _detail = Map<String, dynamic>.from(resp.data);
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _error = resp.message ?? 'Gagal memuat detail transaksi';
      });
    }
  }

  Future<void> _refresh() => _fetchDetail();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Loading state
    if (_loading) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: cs.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 120),
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 16),
              Center(child: Text('Memuat detail transaksi…')),
              SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_error != null) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: cs.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              Icon(Icons.error_outline, size: 48, color: cs.error),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _fetchDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final d = _detail!;
    final List items = (d['detail_transactions'] as List?) ?? [];
    final paymentStatus = (d['payment_status'] ?? '-').toString();
    final shippingStatus = (d['shipping_status'] ?? '-').toString();
    final canRate = ['success', 'paid', 'completed'].contains(paymentStatus.toLowerCase()) ||
        ['delivered', 'completed'].contains(shippingStatus.toLowerCase());

    final int ratedCount = items.where((it) {
      final m = Map<String, dynamic>.from(it as Map);
      final r = m['rating'];
      if (r is Map) {
        final stars = (r['stars'] ?? 0) as int;
        final comment = (r['comment'] ?? '') as String;
        return stars > 0 || comment.trim().isNotEmpty;
      }
      return false;
    }).length;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: cs.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              pinned: true,
              expandedHeight: 160,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Transaction Detail', style: TextStyle(color: cs.onPrimary)),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _Chip(text: '${d['transaction_code']}', icon: Icons.qr_code_2_rounded),
                          const SizedBox(width: 8),
                          // _StatusPill(text: paymentStatus, color: _statusColor(paymentStatus, cs), icon: Icons.payments_rounded),
                          // const SizedBox(width: 8),
                          // _StatusPill(text: shippingStatus, color: cs.secondaryContainer, icon: Icons.local_shipping_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),

            // ---- Body ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    _GlassCard(child: _InfoGrid(detail: d)),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Items', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    const SizedBox(height: 8),
                    // === ADD: chip progres berapa yang sudah dinilai ===
                    if (items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(.1),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.green.withOpacity(.25)),
                              ),
                              child: Text(
                                '$ratedCount/${items.length} sudah dinilai',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),


                    ...items.map((e) {
                      final item = Map<String, dynamic>.from(e);
                      return _ProductTile(
                        item: item,
                        canRate: canRate,
                        onSubmitted: () async => _fetchDetail(),
                      );
                    }),

                    const SizedBox(height: 12),
                    _GlassCard(padding: const EdgeInsets.all(16), child: _TotalSection(detail: d)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----- WIDGETS -----
class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.detail});
  final Map<String, dynamic> detail;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget row(String left, String right, {FontWeight fw = FontWeight.w500}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(left, style: text.bodyMedium!.copyWith(color: Colors.black54))),
            Text(right, style: text.bodyMedium!.copyWith(fontWeight: fw)),
          ],
        ),
      );
    }

    final bengkel = detail['bengkel'] as Map<String, dynamic>?;
    final createdAt = DateTime.tryParse('${detail['created_at']}') ?? DateTime.now();

    final List items = (detail['detail_transactions'] as List?) ?? [];
    final subtotal = items.fold<int>(
      0,
          (prev, it) => prev + ((it['product_price'] ?? (it['product']?['price'] ?? 0)) as int) * (it['qty'] as int),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          row('Bengkel', '${bengkel?['name'] ?? '-'}'),
          row('Tanggal', _fmtDate(createdAt)),
          row('Total Belanja', rupiah(subtotal)),
          row('Ongkir', rupiah(detail['ongkir'] ?? 0)),
          row('Biaya Administrasi', rupiah(detail['administrasi'] ?? 0)),
          const Divider(height: 24),
          row('Grand Total', rupiah(detail['grand_total'] ?? 0), fw: FontWeight.w700),
        ],
      ),
    );
  }
}

class _ProductTile extends StatefulWidget {
  const _ProductTile({
    required this.item,
    required this.canRate,
    required this.onSubmitted,
  });

  final Map<String, dynamic> item;
  final bool canRate;
  final Future<void> Function() onSubmitted;

  @override
  State<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<_ProductTile> {
  double rating = 0;
  final controller = TextEditingController();
  bool posting = false;
  bool _alreadyRated = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.item['rating'];
    if (existing is Map) {
      final stars = (existing['stars'] ?? 0) as int;
      final comment = (existing['comment'] ?? '') as String;
      rating = stars.toDouble();
      controller.text = comment;
      _alreadyRated = stars > 0 || comment.trim().isNotEmpty; // <- tambahkan ini
    }
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_alreadyRated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan sudah terkirim dan sementara tidak bisa diubah.')),
      );
      return;
    }
    if (!widget.canRate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi belum selesai, rating belum bisa dikirim.')),
      );
      return;
    }
    if (rating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 bintang.')),
      );
      return;
    }
    final detailId = widget.item['id'] as int?;
    if (detailId == null) return;

    setState(() => posting = true);
    final res = await RatingViewmodel().ratingProduct(
      detailTransactionId: detailId,
      stars: rating.round().clamp(1, 5),
      comment: controller.text.trim().isEmpty ? null : controller.text.trim(),
    );
    setState(() => posting = false);

    if (!mounted) return;

    if (res.code == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Rating tersimpan')),
      );
      await widget.onSubmitted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Gagal mengirim rating')),
      );
    }
  }

  // === ADD: helper cek apakah item sudah pernah dinilai ===
  bool get _isRated {
    final r = widget.item['rating'];
    if (r is Map) {
      final stars = (r['stars'] ?? 0) as int;
      final comment = (r['comment'] ?? '') as String;
      return stars > 0 || comment.trim().isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    final product = it['product'] as Map<String, dynamic>?;
    final layanan = it['layanan'] as Map<String, dynamic>?; // jaga-jaga kalau ada layanan
    final qty = (it['qty'] ?? 0) as int;
    final price = (it['product_price'] ?? (product?['price'] ?? it['layanan_price'] ?? 0)) as int;
    final subtotal = price * qty;

    final cs = Theme.of(context).colorScheme;

    return _GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _ProductImage(image: product?['image']),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${product?['name'] ?? layanan?['name'] ?? 'Item'}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Qty $qty${product != null ? " • ${product['weight'] ?? 0} kg" : ""}',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Text(rupiah(subtotal), style: Theme.of(context).textTheme.titleSmall),
                      // === ADD: badge status sudah/belum dinilai ===
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            _isRated ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            size: 16,
                            color: _isRated ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isRated ? 'Sudah dinilai' : 'Belum dinilai',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _isRated ? Colors.green[700] : Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ----- Rating box -----
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(.5),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Rating & Ulasan', style: Theme.of(context).textTheme.titleSmall),
                      const Spacer(),
                      if (!widget.canRate)
                        const Tooltip(
                          message: 'Rating aktif setelah transaksi selesai',
                          child: Icon(Icons.lock_clock_rounded, size: 18),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AbsorbPointer(
                    absorbing: !widget.canRate || posting || _alreadyRated, // <- tambahkan
                    child: Opacity(
                      opacity: widget.canRate && !_alreadyRated ? 1 : .5,   // <- tambahkan
                      child: _StarRating(
                        value: rating,
                        onChanged: (v) => setState(() => rating = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    minLines: 2,
                    maxLines: 4,
                    enabled: widget.canRate && !posting && !_alreadyRated,  // <- tambahkan
                    decoration: InputDecoration(
                      hintText: _alreadyRated
                          ? 'Ulasan terkirim — sementara tidak bisa diubah'
                          : (widget.canRate ? 'Tulis ulasan untuk item ini…' : 'Rating aktif setelah transaksi selesai'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: posting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        posting
                            ? 'Mengirim…'
                            : (_alreadyRated ? 'Sudah Dinilai' : 'Kirim Ulasan'), // <- tidak ada "Update"
                      ),
                      onPressed: (posting || _alreadyRated) ? null : _submit,    // <- disable kalau sudah dinilai
                    ),
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

class _TotalSection extends StatelessWidget {
  const _TotalSection({required this.detail});
  final Map<String, dynamic> detail;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final List items = (detail['detail_transactions'] as List?) ?? [];
    final ratedCount = items.where((it) {
      final m = Map<String, dynamic>.from(it);
      return m['rating'] != null; // sudah ada rating dari user
    }).length;
    final subtotal = items.fold<int>(
      0,
          (prev, it) => prev + ((it['product_price'] ?? (it['product']?['price'] ?? it['layanan_price'] ?? 0)) as int) * (it['qty'] as int),
    );

    Widget line(String label, int value, {bool bold = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(label, style: t.bodyMedium)),
            Text(rupiah(value), style: t.bodyMedium!.copyWith(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ],
        ),
      );
    }

    return Column(
      children: [
        line('Subtotal', subtotal),
        line('Ongkir', detail['ongkir'] ?? 0),
        line('Biaya Administrasi', detail['administrasi'] ?? 0),
        const Divider(height: 24),
        line('Grand Total', detail['grand_total'] ?? 0, bold: true),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.padding, this.margin});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8))],
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.image});
  final String? image;

  @override
  Widget build(BuildContext context) {
    final url = image == null ? null : '${dotenv.env["IMAGE_BASE_URL"]}/$image';
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 72,
        height: 72,
        color: const Color(0xFFEFF2F7),
        child: url == null
            ? const Icon(Icons.image_rounded, size: 28, color: Colors.black26)
            : Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color, required this.icon});
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final on = ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black87;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: on),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: on)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    const total = 5;
    return Row(
      children: List.generate(5, (i) {
        final selected = value.round().clamp(0, 5);
        final isFilled = i < selected;
        return GestureDetector(
          onTap: () => onChanged((i + 1).toDouble()), // set 1..5
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
            size: 26,
            color: Colors.amber,
          ),
        );
      }),
    );

  }
}

/// ----- Helpers -----
Color _statusColor(String status, ColorScheme cs) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'success':
    case 'completed':
      return Colors.green.shade400;
    case 'pending':
      return Colors.orange.shade400;
    case 'failed':
    case 'cancelled':
      return Colors.red.shade400;
    default:
      return cs.secondaryContainer;
  }
}

String rupiah(int value) {
  final f = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
  return f.format(value);
}

String _fmtDate(DateTime dt) {
  final f = DateFormat('dd MMM yyyy');
  return f.format(dt.toLocal());
}

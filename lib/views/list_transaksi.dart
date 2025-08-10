// lib/views/transaction_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/viewmodel/transaction_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/transaction_detail_page.dart';
import 'package:intl/intl.dart';

class Transaction {
  final int id;
  final String transactionId;
  final String serviceName;
  final String date;
  final String time;
  final String amount;
  final String status; // 'Completed', 'Pending', 'Failed'

  Transaction({
    required this.id,
    required this.transactionId,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.amount,
    this.status = 'Completed',
  });
}

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final List<Transaction> _transactions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getHistoryTransaction();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _getHistoryTransaction() async {
    try {
      final value = await TransactionViewmodel().getTransactionHistory();
      if (!mounted) return;

      if (value.code == 200) {
        final List raw = (value.data as List?) ?? [];

        final currency = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        final txs = raw.map<Transaction>((e) {
          final txCode = e['transaction_code']?.toString() ?? '-';
          final id = e['id'] ?? 0;

          final createdAtStr = e['created_at']?.toString() ?? '';
          final createdAt = DateTime.tryParse(createdAtStr);
          final date =
          createdAt != null ? DateFormat('d MMMM y').format(createdAt) : '-';
          final time =
          createdAt != null ? DateFormat('hh:mm a').format(createdAt) : '';

          final grand = (e['grand_total'] as num?)?.toInt() ?? 0;
          final amount = currency.format(grand);

          final payment = (e['payment_status']?.toString() ?? '').toLowerCase();
          final shipping = (e['shipping_status']?.toString() ?? '').toLowerCase();

          String status;
          if (payment == 'paid' || payment == 'success' || payment == 'paid_off') {
            status = 'Completed';
          } else if (payment == 'failed' || payment == 'cancelled') {
            status = 'Failed';
          } else {
            status = 'Pending';
          }

          String serviceName;
          final bengkelName = e['bengkel']?['name']?.toString() ?? 'Transaksi Bengkel';
          if (e['booking_id'] != null) {
            serviceName = 'Booking #${e['booking_id']} • $bengkelName';
          } else if (e['product_id'] != null) {
            serviceName = 'Produk #${e['product_id']} • $bengkelName';
          } else {
            serviceName = bengkelName;
          }

          return Transaction(
            id: id,
            transactionId: '#$txCode',
            serviceName: serviceName,
            date: date,
            time: time,
            amount: amount,
            status: status,
          );
        }).toList();

        setState(() {
          _transactions
            ..clear()
            ..addAll(txs);
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _loading = false;
          _error = value.message ?? 'Gagal memuat transaksi';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Transaksi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _getHistoryTransaction,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(child: Text(_error!)),
            ),
          ],
        )
            : _transactions.isEmpty
            ? ListView(
          children: const [
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('Anda belum memiliki riwayat transaksi.'),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final transaction = _transactions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 2.0,
              child: GestureDetector(
                onTap: () {
                  dynamic data = dummyJson['data'];
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionDetailPage(transactionId: transaction.id,),));},
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            transaction.transactionId,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(transaction.status)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              transaction.status,
                              style: TextStyle(
                                color: _getStatusColor(transaction.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        transaction.serviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${transaction.date}, ${transaction.time}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.money,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 5),
                          Text(
                            transaction.amount,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF4A6B6B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


final dummyJson = {
  "code": 200,
  "status": "success",
  "message": "Detail transaksi berhasil diambil.",
  "data": {
    "id": 1,
    "transaction_code": "TRANS-439",
    "user_id": 3,
    "bengkel_id": 1,
    "booking_id": null,
    "product_id": null,
    "layanan_id": null,
    "administrasi": 10000,
    "payment_status": "pending",
    "shipping_status": "Pending",
    "ongkir": 15000,
    "grand_total": 225000,
    "created_at": "2025-07-12T03:26:22.000000Z",
    "updated_at": "2025-07-12T03:26:22.000000Z",
    "withdrawn_at": null,
    "detail_transactions": [
      {
        "id": 1,
        "transaction_id": 1,
        "product_id": 1,
        "layanan_id": null,
        "qty": 1,
        "product_price": 200000,
        "layanan_price": null,
        "created_at": "2025-07-12T03:26:22.000000Z",
        "updated_at": "2025-07-12T03:26:22.000000Z",
        "product": {
          "id": 1,
          "name": "oli samping",
          "image": "1742284210.jpg",
          "description": "ini deskripsi",
          "bengkel_id": 1,
          "price": 200000,
          "weight": 2,
          "stock": 9,
          "created_at": "2025-03-18T07:50:10.000000Z",
          "updated_at": "2025-07-22T15:13:27.000000Z"
        }
      }
    ],
    "bengkel": {
      "id": 1,
      "pemilik_id": 2,
      "specialist_id": null,
      "name": "Bengkel Ngawi",
      "image": "1742284047.jpg",
      "description": "ini deskripsi",
      "alamat": "jawa",
      "latitude": "-6.20150000",
      "longitude": "106.81700000",
      "created_at": "2025-03-18T07:47:27.000000Z",
      "updated_at": "2025-03-18T07:47:27.000000Z",
      "kecamatan_id": 2,
      "kelurahan_id": 8
    },
    "layanan": null
  }
};

// lib/views/transaction_list_page.dart
import 'package:flutter/material.dart';

// Model data dummy untuk Transaksi
class Transaction {
  final String transactionId;
  final String serviceName;
  final String date;
  final String time;
  final String amount;
  final String status; // Misal: 'Completed', 'Pending', 'Failed'

  Transaction({
    required this.transactionId,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.amount,
    this.status = 'Completed', // Default status Completed
  });
}

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  // Data dummy untuk daftar transaksi
  final List<Transaction> _transactions = [
    Transaction(
      transactionId: '#TRX123456',
      serviceName: 'Ganti Oli Mesin',
      date: '23 Juli 2025',
      time: '10:00 AM',
      amount: 'Rp 150.000',
      status: 'Completed',
    ),
    Transaction(
      transactionId: '#TRX123457',
      serviceName: 'Service Rutin 10.000 KM',
      date: '20 Juli 2025',
      time: '02:30 PM',
      amount: 'Rp 300.000',
      status: 'Completed',
    ),
    Transaction(
      transactionId: '#TRX123458',
      serviceName: 'Perbaikan Rem',
      date: '18 Juli 2025',
      time: '09:00 AM',
      amount: 'Rp 250.000',
      status: 'Pending', // Contoh status pending
    ),
    Transaction(
      transactionId: '#TRX123459',
      serviceName: 'Ganti Ban Depan',
      date: '15 Juli 2025',
      time: '04:00 PM',
      amount: 'Rp 400.000',
      status: 'Completed',
    ),
    Transaction(
      transactionId: '#TRX123460',
      serviceName: 'Tune Up Mesin',
      date: '10 Juli 2025',
      time: '11:00 AM',
      amount: 'Rp 200.000',
      status: 'Completed',
    ),
  ];

  // Helper function to determine status color
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Transaksi',
          style: TextStyle(
            color: Colors.black, // Judul warna hitam
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Background transparan
        elevation: 0, // Tanpa shadow
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // Panah kembali warna hitam
      ),
      body: _transactions.isEmpty
          ? const Center(child: Text('Anda belum memiliki riwayat transaksi.'))
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
                                color: _getStatusColor(
                                  transaction.status,
                                ).withOpacity(0.2),
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
                                color: Color(
                                  0xFF4A6B6B,
                                ), // Warna hijau gelap seperti tombol
                              ),
                            ),
                          ],
                        ),
                        // Anda bisa menambahkan tombol detail di sini jika diperlukan
                        // const SizedBox(height: 10),
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: OutlinedButton(
                        //     onPressed: () {
                        //       // Navigasi ke halaman detail transaksi
                        //       debugPrint('Lihat detail transaksi ${transaction.transactionId}');
                        //     },
                        //     child: const Text('Lihat Detail'),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

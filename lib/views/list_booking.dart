// lib/views/booking_list_page.dart
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/config/pref.dart';
import 'package:flutter_bengkelin_user/viewmodel/booking_viewmodel.dart';
import 'package:intl/intl.dart';

import '../model/user_booking.dart';
import 'home_page.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  bool _isLoading = true;
  List<UserBookingModel> _listUserBooking = [];

  Future<void> getUserBooking() async {
    try {
      final value = await BookingViewmodel().userBooking();

      if (value.code == 200) {
        final List<dynamic> listData = value.data as List<dynamic>;
        setState(() {
          _listUserBooking = listData
              .map((e) => UserBookingModel.fromJson(e))
              .toList();
        });
      } else if (value.code == 401) {
        await Session().logout();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error fetching booking: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data booking.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    getUserBooking();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Riwayat Booking Anda'),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1D2A39),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D2A39)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listUserBooking.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              itemCount: _listUserBooking.length,
              itemBuilder: (context, index) {
                final booking = _listUserBooking[index];
                // 2. Gunakan widget Card yang baru
                return _BookingCard(booking: booking);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Booking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua riwayat booking Anda akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final UserBookingModel booking;

  const _BookingCard({required this.booking});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('HH:mm').format(date);
  }

  Widget _buildStatusBadge(String? status) {
    final ({Color backgroundColor, Color textColor}) statusInfo =
        _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? 'Unknown',
        style: TextStyle(
          color: statusInfo.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  ({Color backgroundColor, Color textColor}) _getStatusInfo(String? status) {
    switch (status?.toLowerCase()) {
      case 'diterima':
        return (
          backgroundColor: const Color(0xFFE0F8F0),
          textColor: const Color(0xFF00875A),
        );
      case 'pending':
        return (
          backgroundColor: const Color(0xFFFFF4DE),
          textColor: const Color(0xFFFFAA00),
        );
      case 'dibatalkan':
        return (
          backgroundColor: const Color(0xFFFFECEB),
          textColor: const Color(0xFFDE350B),
        );
      case 'selesai':
        return (
          backgroundColor: const Color(0xFFE6F7FF),
          textColor: const Color(0xFF0065FF),
        );
      default:
        return (
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.grey.shade800,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          // TODO: Navigasi ke halaman detail booking
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailPage(bookingId: booking.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Header: Logo, Nama Bengkel, Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade100,
                    child: Image.asset(
                      'assets/logo_bengkel.png',
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.build_circle_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.bengkel?.name ?? "Nama Bengkel",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1D2A39),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Booking ID: #${booking.id}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Menggunakan status badge yang sudah dibuat
                  _buildStatusBadge(
                    "Pending",
                  ), // <-- Ganti dengan booking.status
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1),
              ),
              // Bagian Footer: Tanggal dan Waktu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: _formatDate(booking.createdAt),
                  ),
                  _buildInfoRow(
                    icon: Icons.access_time_outlined,
                    text: _formatTime(booking.createdAt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

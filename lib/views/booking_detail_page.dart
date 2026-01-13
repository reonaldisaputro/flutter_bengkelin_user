import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/config/network.dart';
import 'package:flutter_bengkelin_user/config/pref.dart';
import 'package:flutter_bengkelin_user/viewmodel/booking_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';

class BookingDetailPage extends StatefulWidget {
  final int bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _bookingDetail;

  Future<void> getBookingDetail() async {
    try {
      final value = await BookingViewmodel().detailBooking(
        bookingId: widget.bookingId,
      );

      if (value.code == 200) {
        setState(() {
          _bookingDetail = value.data as Map<String, dynamic>;
        });
      } else if (value.code == 401) {
        await Session().logout();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value.message ?? "Gagal memuat detail booking."),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching booking detail: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat detail booking.")),
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
    getBookingDetail();
    super.initState();
  }

  String _formatDate(String? date) {
    if (date == null) return '-';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String? time) {
    if (time == null) return '-';
    try {
      final timeParts = time.split(':');
      if (timeParts.length >= 2) {
        return '${timeParts[0]}:${timeParts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  Widget _buildStatusBadge(String? status) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Detail Booking'),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1D2A39),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D2A39)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookingDetail == null
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 16),
                  _buildBengkelSection(),
                  const SizedBox(height: 16),
                  _buildVehicleSection(),
                  const SizedBox(height: 16),
                  _buildBookingInfoSection(),
                  const SizedBox(height: 16),
                  if (_bookingDetail!['catatan_tambahan'] != null)
                    _buildNotesSection(),
                  const SizedBox(height: 16),
                  _buildUserSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Detail Booking Tidak Ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking ID: #${_bookingDetail!['id']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2A39),
                ),
              ),
              _buildStatusBadge(_bookingDetail!['booking_status']),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(_bookingDetail!['tanggal_booking']),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(_bookingDetail!['waktu_booking']),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBengkelSection() {
    final bengkel = _bookingDetail!['bengkel'] as Map<String, dynamic>?;
    if (bengkel == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Bengkel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2A39),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  '${dotenv.env["IMAGE_BASE_URL"]}/${bengkel['image']}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.build_circle,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bengkel['name'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2A39),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            bengkel['alamat'] ?? '-',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Kendaraan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2A39),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Brand', _bookingDetail!['brand'] ?? '-'),
          const SizedBox(height: 12),
          _buildDetailRow('Model', _bookingDetail!['model'] ?? '-'),
          const SizedBox(height: 12),
          _buildDetailRow('Plat Nomor', _bookingDetail!['plat'] ?? '-'),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Tahun Pembuatan',
            _bookingDetail!['tahun_pembuatan']?.toString() ?? '-',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Kilometer',
            '${_bookingDetail!['kilometer']?.toString() ?? '-'} km',
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Transmisi', _bookingDetail!['transmisi'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildBookingInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Booking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2A39),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Tanggal Booking',
            _formatDate(_bookingDetail!['tanggal_booking']),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Waktu Booking',
            _formatTime(_bookingDetail!['waktu_booking']),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Status', _bookingDetail!['booking_status'] ?? '-'),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Dibuat Pada',
            _formatDate(_bookingDetail!['created_at']),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan Tambahan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2A39),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _bookingDetail!['catatan_tambahan'] ?? '-',
              style: const TextStyle(fontSize: 14, color: Color(0xFF1D2A39)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
    final user = _bookingDetail!['user'] as Map<String, dynamic>?;
    if (user == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pengguna',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2A39),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Nama', user['name'] ?? '-'),
          const SizedBox(height: 12),
          _buildDetailRow('Email', user['email'] ?? '-'),
          const SizedBox(height: 12),
          _buildDetailRow('No. Telepon', user['phone_number'] ?? '-'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  'Alamat',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              Expanded(
                child: Text(
                  user['alamat'] ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1D2A39),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1D2A39),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

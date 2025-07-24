// lib/views/booking_list_page.dart
import 'package:flutter/material.dart';

// Model data dummy untuk booking
class Booking {
  final String bengkelName;
  final String bookingId;
  final String
  dateTime; // Bisa diubah ke DateTime object jika perlu manipulasi tanggal/waktu
  final String status; // Misal: 'active', 'cancelled', 'completed'

  Booking({
    required this.bengkelName,
    required this.bookingId,
    required this.dateTime,
    this.status = 'active', // Default status aktif
  });
}

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  // Data dummy untuk daftar booking
  final List<Booking> _bookings = [
    Booking(
      bengkelName: 'Bengkel Pak Hambali',
      bookingId: '#PJT193E4',
      dateTime: 'Monday 8:00- 9:00 am July 31, 2023',
    ),
    Booking(
      bengkelName: 'Bengkel Pak Hambali',
      bookingId: '#PJT193E4',
      dateTime: 'Monday 8:00- 9:00 am July 31, 2023',
    ),
    Booking(
      bengkelName: 'Bengkel Pak Hambali',
      bookingId: '#PJT193E4',
      dateTime: 'Monday 8:00- 9:00 am July 31, 2023',
    ),
    Booking(
      bengkelName: 'Bengkel Pak Hambali',
      bookingId: '#PJT193E4',
      dateTime: 'Monday 8:00- 9:00 am July 31, 2023',
    ),
    Booking(
      bengkelName: 'Bengkel Pak Hambali',
      bookingId: '#PJT193E4',
      dateTime: 'Monday 8:00- 9:00 am July 31, 2023',
    ),
  ];

  // Fungsi placeholder untuk membatalkan booking
  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembatalan'),
          content: Text(
            'Anda yakin ingin membatalkan booking ${booking.bookingId}?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () {
                // Di sini Anda akan memanggil API untuk membatalkan booking
                // Contoh: YourBookingService().cancelBooking(booking.bookingId);
                debugPrint('Membatalkan booking: ${booking.bookingId}');
                // Setelah berhasil dari API, Anda mungkin ingin menghapus item dari list atau mengubah status
                setState(() {
                  // Contoh: Menghapus dari list (jika pembatalan berarti dihapus dari UI)
                  _bookings.remove(booking);
                  // Atau mengubah status (jika pembatalan berarti statusnya berubah, bukan dihapus)
                  // int index = _bookings.indexOf(booking);
                  // if (index != -1) {
                  //   _bookings[index] = Booking(
                  //     bengkelName: booking.bengkelName,
                  //     bookingId: booking.bookingId,
                  //     dateTime: booking.dateTime,
                  //     status: 'cancelled', // Perbarui status
                  //   );
                  // }
                });
                Navigator.of(context).pop(); // Tutup dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking ${booking.bookingId} berhasil dibatalkan.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Warna merah untuk batal
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Booking',
          style: TextStyle(
            color: Colors.black, // Judul warna hitam sesuai gambar
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Background transparan
        elevation: 0, // Tanpa shadow
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // Panah kembali warna hitam
      ),
      body: _bookings.isEmpty
          ? const Center(child: Text('Anda belum memiliki booking.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
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
                          children: [
                            // Logo Bengkel (contoh: CircleAvatar dengan Image.asset)
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              // Ganti dengan logo bengkel yang sebenarnya
                              child: Image.asset(
                                'assets/logo_bengkel.png', // <-- Pastikan Anda memiliki aset ini
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.build,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.bengkelName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    booking.bookingId,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Tombol Batalkan
                            ElevatedButton(
                              onPressed: () => _cancelBooking(booking),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Warna merah
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                minimumSize:
                                    Size.zero, // Meminimalkan ukuran tombol
                                tapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, // Meminimalkan area sentuh
                              ),
                              child: const Text(
                                'Batalkan',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // Bagian Tanggal dan Waktu
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A6B6B), // Warna hijau gelap
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Agar container sesuai konten
                            children: [
                              const Icon(
                                Icons.watch_later_outlined, // Icon jam
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                booking.dateTime,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/model/user_model.dart'; // Pastikan path ini benar
import 'package:flutter_bengkelin_user/viewmodel/profile_viewmodel.dart'; // Pastikan path ini benar
import 'package:flutter_bengkelin_user/views/edit_profile_page.dart';
import 'package:flutter_bengkelin_user/views/list_booking.dart'; // Perbaikan nama file
import 'package:flutter_bengkelin_user/views/list_transaksi.dart'; // Perbaikan nama file

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true; // Untuk menampilkan indikator loading
  UserModel? _users; // Untuk menyimpan data profil pengguna dari backend

  @override
  void initState() {
    super.initState();
    _getUserProfile(); // Panggil fungsi untuk memuat data saat inisialisasi
  }

  // Fungsi untuk mengambil data profil dari API
  Future<void> _getUserProfile() async {
    setState(() {
      _isLoading = true;
      _users = null; // Reset data pengguna sebelum memuat ulang
    });

    try {
      final respValue = await ProfileViewmodel().getUserProfile();

      if (!mounted) return;

      if (respValue.code == 200 && respValue.status == 'success') {
        if (respValue.data != null) {
          setState(() {
            _users = UserModel.fromJson(
              respValue.data,
            ); // Konversi JSON ke UserModel
            _isLoading = false; // Hentikan loading
          });
          debugPrint('User profile loaded successfully: ${_users?.name}');
        } else {
          setState(() {
            _isLoading = false;
            _users = null;
            debugPrint(
              'Failed to load user profile: Status 200/Success but data is null.',
            );
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _users = null;
          debugPrint(
            'Failed to load user profile: Code ${respValue.code}, Status: ${respValue.status}, Message: ${respValue.error ?? respValue.message}',
          );
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _users = null;
        debugPrint('Error loading user profile: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih sesuai gambar
      appBar: AppBar(
        backgroundColor: Colors.grey, // Warna AppBar abu-abu
        elevation: 0,
        foregroundColor: Colors.white, // Warna teks dan ikon di app bar
        title: const Text('Pengaturan'), // Sesuai gambar
      ),
      body:
          _isLoading // Tampilkan CircularProgressIndicator jika sedang loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey,
                ), // Warna loading sesuai tema
              ),
            )
          : _users ==
                null // Tampilkan pesan error jika _users null setelah loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  const Text(
                    'Gagal memuat profil. Silakan coba lagi.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _getUserProfile, // Tombol untuk memuat ulang
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                // Bagian Profil (CircleAvatar dan Nama/Status)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    // Ini adalah Row utama
                    children: [
                      CircleAvatar(
                        radius: 30, // Ukuran avatar sesuai gambar
                        backgroundColor: Colors
                            .grey[800], // Background fallback jika gambar tidak ada
                        child: ClipOval(
                          // Agar ikon person juga berbentuk lingkaran
                          child: Image.asset(
                            'assets/profile1.png', // Fallback image jika NetworkImage gagal atau URL kosong
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 30, // Sesuaikan ukuran ikon di sini
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        // Expanded ini akan mengambil sisa ruang yang tersedia
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // Mengambil nama dari _users, dengan fallback jika null
                              _users!.name,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 20, 20, 20),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_users == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Data profil belum lengkap. Coba lagi.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfilePage(
                                      userName: _users!.name,
                                      userEmail: _users!.email,
                                      userPhoneNumber: _users!.phoneNumber,
                                      userAddress: _users!
                                          .alamat, // Menggunakan 'alamat'
                                      userPhotoUrl:
                                          '', // Tidak ada URL dari backend, berikan string kosong
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  debugPrint(
                                    'Profile updated. Reloading data...',
                                  );
                                  _getUserProfile(); // Muat ulang profil setelah kembali dari edit
                                }
                              },
                              child: Column(
                                // Mengganti Text langsung dengan Column
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // Menampilkan kecamatan dari _users.alamat atau properti kecamatan
                                    _users!
                                        .alamat, // Menggunakan alamat secara keseluruhan
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  // Tambahkan teks Kelurahan di bawah Kecamatan
                                  Text(
                                    // Anda perlu menyesuaikan ini untuk mengambil kelurahan dari model Anda
                                    // Contoh: _users!.kelurahan ?? 'Kelurahan tidak tersedia',
                                    // Jika kelurahan ada di dalam string alamat, Anda perlu parsing.
                                    // Untuk sementara, saya akan menggunakan alamat lagi atau string kosong.
                                    '', // Ganti dengan _users!.kelurahan atau hasil parsing alamat
                                    style: const TextStyle(
                                      color: Colors
                                          .black54, // Warna sedikit berbeda
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey, height: 1), // Garis pemisah
                // Bagian List Pengaturan
                _buildSettingsSection(
                  context,
                  'AKUN', // Sesuai gambar
                  [
                    _buildSettingsItem(
                      context,
                      icon: Icons.edit,
                      title: 'Edit Profile', // Sesuaikan dengan gambar
                      subtitle:
                          'Edit Nama,Email dan Gambar', // Sesuaikan dengan gambar
                      onTap: () async {
                        if (_users == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Data profil belum lengkap. Coba lagi.',
                              ),
                            ),
                          );
                          return;
                        }
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              userName: _users!.name,
                              userEmail: _users!.email,
                              userPhoneNumber: _users!.phoneNumber,
                              userAddress:
                                  _users!.alamat, // Menggunakan 'alamat'
                              userPhotoUrl:
                                  '', // Tidak ada URL dari backend, berikan string kosong
                            ),
                          ),
                        );
                        if (result == true) {
                          debugPrint('Profile updated. Reloading data...');
                          _getUserProfile(); // Muat ulang profil setelah kembali dari edit
                        }
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      icon: Icons.menu_book_sharp, // Sesuai gambar
                      title: 'List Transkasi', // Sesuai gambar
                      subtitle: 'Lihat daftar transaksi Anda', // Ubah subtitle
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionListPage(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      icon: Icons.person_outline, // Sesuai gambar
                      title: 'List Booking', // Sesuai gambar
                      subtitle: 'Lihat daftar booking Anda', // Ubah subtitle
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookingListPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  // Widget pembantu untuk membangun bagian pengaturan
  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600], // Warna abu-abu untuk judul seksi
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ...children,
        const SizedBox(height: 10), // Spasi antar seksi
      ],
    );
  }

  // Widget pembantu untuk membangun item pengaturan
  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey), // Warna ikon abu-abu
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
      subtitle: subtitle != null && subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.black, fontSize: 13),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
    );
  }
}

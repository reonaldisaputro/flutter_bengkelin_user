// lib/view/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/viewmodel/auth_viewmodel.dart';
import 'package:flutter_bengkelin_user/viewmodel/service_viewmodel.dart';
import 'package:flutter_bengkelin_user/model/kecamatan_model.dart'; // Pastikan path ini benar
import 'package:flutter_bengkelin_user/model/kelurahan_model.dart'; // Pastikan path ini benar
import 'package:flutter_bengkelin_user/config/model/resp.dart'; // Pastikan import ini benar

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  KecamatanModel? selectedKecamatan;
  KelurahanModel? selectedKelurahan;

  List<KecamatanModel> kecamatanModelList = [];
  List<KelurahanModel> kelurahanModelList = [];

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Tambahkan variabel untuk loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getKecamatan();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> getKecamatan() async {
    try {
      final Resp response = await ServiceViewmodel().kecamatan();
      // Periksa 'code' atau 'statusCode' dari respons API Anda
      if (response.code == 200 || response.statusCode == 200) {
        if (response.data is List) {
          // Pastikan 'data' adalah List
          setState(() {
            kecamatanModelList = (response.data as List)
                .map<KecamatanModel>((json) => KecamatanModel.fromJson(json))
                .toList();
          });
        } else {
          debugPrint('Error: Data kecamatan bukan list: ${response.data}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Format data kecamatan tidak valid dari server.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat kecamatan: ${response.message ?? response.error ?? 'Terjadi kesalahan tidak dikenal'}',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching kecamatan: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching kecamatan: $e')));
    }
  }

  Future<void> getKelurahan(int kecamatanId) async {
    try {
      final Resp response = await ServiceViewmodel().kelurahan(
        kecamatanId: kecamatanId,
      );
      if (response.code == 200 || response.statusCode == 200) {
        if (response.data is List) {
          // Pastikan 'data' adalah List
          setState(() {
            kelurahanModelList = (response.data as List)
                .map<KelurahanModel>((json) => KelurahanModel.fromJson(json))
                .toList();
          });
        } else {
          debugPrint('Error: Data kelurahan bukan list: ${response.data}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Format data kelurahan tidak valid dari server.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat kelurahan: ${response.message ?? response.error ?? 'Terjadi kesalahan tidak dikenal'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching kelurahan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            const Text(
              'Daftar Akun',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Daftar akun supaya bisa menggunakan fitur\ndidalam aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: 'Nama Lengkap',
                hintStyle: TextStyle(color: Colors.grey[500]),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Alamat Email',
                hintStyle: TextStyle(color: Colors.grey[500]),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<KecamatanModel>(
              value: selectedKecamatan,
              hint: const Text('Pilih Kecamatan'),
              items: kecamatanModelList.map((kec) {
                return DropdownMenuItem<KecamatanModel>(
                  value: kec,
                  child: Text(kec.name),
                );
              }).toList(),
              onChanged: (KecamatanModel? newValue) {
                setState(() {
                  selectedKecamatan = newValue;
                  selectedKelurahan = null; // Reset kelurahan
                  kelurahanModelList = []; // Kosongkan daftar kelurahan
                });
                if (newValue != null) {
                  getKelurahan(newValue.id);
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<KelurahanModel>(
              value: selectedKelurahan,
              hint: const Text('Pilih Kelurahan'),
              items: kelurahanModelList.map((kel) {
                return DropdownMenuItem<KelurahanModel>(
                  value: kel,
                  child: Text(kel.name),
                );
              }).toList(),
              onChanged: (KelurahanModel? newValue) {
                setState(() {
                  selectedKelurahan = newValue;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Kata Sandi',
                hintStyle: TextStyle(color: Colors.grey[500]),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  child: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Konfirmasi Kata Sandi',
                hintStyle: TextStyle(color: Colors.grey[500]),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  child: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _handleRegister, // Disable button when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6B6B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'atau',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            // Placeholder for social logins
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                // Add social login buttons here if needed
              ],
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sudah memiliki akun?',
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Kembali ke halaman sebelumnya (misal Login)
                  },
                  child: const Text(
                    'Masuk Sekarang',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A6B6B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // Aksi untuk "Nanti Saja"
              },
              child: const Text(
                'Nanti Saja',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua kolom harus diisi')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi dan konfirmasi kata sandi tidak cocok'),
        ),
      );
      return;
    }

    if (selectedKecamatan == null || selectedKelurahan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih Kecamatan dan Kelurahan')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Resp response = await AuthViewmodel().register(
        name: fullName,
        email: email,
        phone: "0895375837434",
        kecamatanId: selectedKecamatan!.id.toString(),
        kelurahanId: selectedKelurahan!.id.toString(),
        password: password,
      );

      setState(() {
        _isLoading = false;
      });

      if ((response.success == true) ||
          (response.code == 200 || response.statusCode == 200)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Registrasi berhasil!')),
        );

        Navigator.pop(
          context,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ??
                  response.error ??
                  'Registrasi gagal. Silakan coba lagi.',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat registrasi: $e')),
      );
      debugPrint(
        'Error during registration: $e',
      );
    }
  }
}

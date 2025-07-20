// lib/views/user/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/config/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bengkelin_user/config/model/resp.dart';
import 'package:flutter_bengkelin_user/model/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhoneNumber;
  final String userAddress;
  final String? userPhotoUrl;

  const EditProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userPhoneNumber,
    required this.userAddress,
    this.userPhotoUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
    _phoneController = TextEditingController(text: widget.userPhoneNumber);
    _addressController = TextEditingController(text: widget.userAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');

      if (authToken == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autentikasi diperlukan. Silakan login ulang.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> requestBody = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'alamat': _addressController.text,
      };

      // --- PENTING: GANTI DENGAN URL UPDATE PROFIL ANDA YANG SEBENARNYA ---
      // Karena Anda tidak ingin mengubah endpoint.dart, saya menuliskannya langsung.
      // Jika API_ENDPOINTS Anda sebenarnya adalah variabel global, silakan akses di sini.
      const String updateProfileUrl =
          "https://your-api-base-url.com/user/update-profile";

      try {
        // --- Perbaikan Pemanggilan Metode Network (non-static) ---
        // Memanggil metode dari instance _network
        final responseMap = await Network.putApiWithHeaders(
          // Menggunakan _network instance
          updateProfileUrl, // Menggunakan URL yang didefinisikan di sini
          requestBody,
          authToken as Map<String, dynamic>,
        );

        final resp = Resp.fromJson(responseMap);

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (resp.code == 200 && resp.status == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resp.message ?? 'Profil berhasil diperbarui!'),
            ),
          );
          if (resp.data != null) {
            Navigator.pop(context, UserModel.fromJson(resp.data));
          } else {
            Navigator.pop(context, null);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resp.message ?? 'Gagal memperbarui profil. Silakan coba lagi.',
              ),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
        );
        debugPrint('Error updating profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: const Color(0xFF4A6B6B),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A6B6B)),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.userPhotoUrl != null &&
                  widget.userPhotoUrl!.isNotEmpty
                  ? CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(widget.userPhotoUrl!),
              )
                  : CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                child: Image.asset(
                  'assets/profile1.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Masukkan email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  )
                      : const Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

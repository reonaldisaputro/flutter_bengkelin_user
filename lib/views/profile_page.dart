import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/config/pref.dart';
import 'package:flutter_bengkelin_user/model/user_model.dart';
import 'package:flutter_bengkelin_user/viewmodel/profile_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/edit_profile_page.dart';

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
    getUserProfile();
  }

  getUserProfile() async {
    setState(() {
      _isLoading = true;
      _users = null;
    });

    try {
      final respValue = await ProfileViewmodel()
          .getUserProfile();

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
            _users = null; // Data null meskipun status 200 dan sukses
            debugPrint(
              'Failed to load user profile: Status 200/Success but data is null.',
            );
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _users = null; // Gagal memuat karena kode/status tidak sesuai
          debugPrint(
            'Failed to load user profile: Code ${respValue.code}, Status: ${respValue.status}, Message: ${respValue.error ?? respValue.message}',
          );
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _users = null; // Tangani error jaringan atau lainnya
        debugPrint('Error loading user profile: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: const Color(0xFF4A6B6B),
        foregroundColor: Colors.white,
      ),
      body:
      _isLoading // Tampilkan CircularProgressIndicator jika sedang loading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A6B6B)),
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
              'Gagal memuat profil atau belum login.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed:
              getUserProfile,
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // _users!.profilePicture != null &&
              //     _users!.profilePictureUrl!.isNotEmpty
              //     ? CircleAvatar(
              //   radius: 60,
              //   backgroundColor: Colors.grey[200],
              //   backgroundImage: NetworkImage(
              //     _users!.profilePictureUrl!,
              //   ),
              // )
              //     : CircleAvatar(
              //   radius: 60,
              //   backgroundColor: Colors.grey[200],
              //   child: Image.asset(
              //     'assets/profile1.png',
              //     fit: BoxFit.cover,
              //     errorBuilder: (context, error, stackTrace) {
              //       return const Icon(
              //         Icons.person,
              //         size: 60,
              //         color: Colors.grey,
              //       );
              //     },
              //   ),
              // ),
              CircleAvatar(
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
              Text(
                _users!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _users!.email,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 10),
              Text(
                _users!.phoneNumber,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 10),
              Text(
                _users!.alamat ?? 'Tidak Ada Alamat',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
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
                          userName: _users!.name ?? '',
                          userEmail: _users!.email ?? '',
                          userPhoneNumber: _users!.phoneNumber ?? '',
                          userAddress: _users!.alamat ?? '',
                          userPhotoUrl: "",
                        ),
                      ),
                    );

                    if (result == true) {
                      debugPrint('Profile updated. Reloading data...');
                      getUserProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Edit Profil',
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

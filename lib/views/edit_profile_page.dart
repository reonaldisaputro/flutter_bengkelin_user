import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/config/model/resp.dart';
import 'package:flutter_bengkelin_user/model/kecamatan_model.dart';
import 'package:flutter_bengkelin_user/model/kelurahan_model.dart';
import 'package:flutter_bengkelin_user/viewmodel/profile_viewmodel.dart';
import 'package:flutter_bengkelin_user/viewmodel/service_viewmodel.dart';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhoneNumber;
  final String userAddress;
  final String? userPhotoUrl;
  final int? kecamatanId;
  final int? kelurahanId;

  const EditProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userPhoneNumber,
    required this.userAddress,
    this.userPhotoUrl,
    this.kecamatanId,
    this.kelurahanId,
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

  // Kecamatan & Kelurahan
  List<KecamatanModel> _kecamatanList = [];
  List<KelurahanModel> _kelurahanList = [];
  KecamatanModel? _selectedKecamatan;
  KelurahanModel? _selectedKelurahan;

  final ProfileViewmodel _profileViewmodel = ProfileViewmodel();
  final ServiceViewmodel _serviceViewmodel = ServiceViewmodel();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
    _phoneController = TextEditingController(text: widget.userPhoneNumber);
    _addressController = TextEditingController(text: widget.userAddress);
    _fetchKecamatan();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchKecamatan() async {
    try {
      final Resp response = await _serviceViewmodel.kecamatan();
      if (response.code == 200 || response.statusCode == 200) {
        if (response.data is List) {
          setState(() {
            _kecamatanList = (response.data as List)
                .map<KecamatanModel>((json) => KecamatanModel.fromJson(json))
                .toList();

            // Set selected kecamatan if user already has one
            if (widget.kecamatanId != null && widget.kecamatanId != 0) {
              try {
                _selectedKecamatan = _kecamatanList
                    .firstWhere((k) => k.id == widget.kecamatanId);
                _fetchKelurahan(_selectedKecamatan!.id);
              } catch (_) {
                // kecamatan not found in list
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching kecamatan: $e");
    }
  }

  Future<void> _fetchKelurahan(int kecamatanId) async {
    try {
      final Resp response =
          await _serviceViewmodel.kelurahan(kecamatanId: kecamatanId);
      if (response.code == 200 || response.statusCode == 200) {
        if (response.data is List) {
          setState(() {
            _kelurahanList = (response.data as List)
                .map<KelurahanModel>((json) => KelurahanModel.fromJson(json))
                .toList();

            // Set selected kelurahan if user already has one
            if (widget.kelurahanId != null && widget.kelurahanId != 0) {
              try {
                _selectedKelurahan = _kelurahanList
                    .firstWhere((k) => k.id == widget.kelurahanId);
              } catch (_) {
                // kelurahan not found in list
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching kelurahan: $e");
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Resp resp = await _profileViewmodel.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        alamat: _addressController.text,
        kecamatanId: _selectedKecamatan?.id,
        kelurahanId: _selectedKelurahan?.id,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (resp.code == 200 || resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp.message ?? 'Profil berhasil diperbarui!'),
          ),
        );
        Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TODO: Photo profile upload - hidden for now
                    // Center(
                    //   child: Stack(
                    //     children: [
                    //       CircleAvatar(
                    //         radius: 60,
                    //         backgroundColor: Colors.grey[200],
                    //         backgroundImage: _selectedImage != null
                    //             ? FileImage(_selectedImage!)
                    //             : (widget.userPhotoUrl != null &&
                    //                         widget.userPhotoUrl!.isNotEmpty
                    //                     ? NetworkImage(widget.userPhotoUrl!)
                    //                     : null)
                    //                 as ImageProvider<Object>?,
                    //         child: _selectedImage == null &&
                    //                 (widget.userPhotoUrl == null ||
                    //                     widget.userPhotoUrl!.isEmpty)
                    //             ? ClipOval(
                    //                 child: Image.asset(
                    //                   'assets/profile1.png',
                    //                   fit: BoxFit.cover,
                    //                   errorBuilder:
                    //                       (context, error, stackTrace) {
                    //                     return const Icon(
                    //                       Icons.person,
                    //                       size: 60,
                    //                       color: Colors.grey,
                    //                     );
                    //                   },
                    //                 ),
                    //               )
                    //             : null,
                    //       ),
                    //       Positioned(
                    //         bottom: 0,
                    //         right: 0,
                    //         child: GestureDetector(
                    //           onTap: _pickImage,
                    //           child: Container(
                    //             padding: const EdgeInsets.all(4),
                    //             decoration: BoxDecoration(
                    //               color: Colors.teal[700],
                    //               shape: BoxShape.circle,
                    //               border: Border.all(
                    //                 color: Colors.white,
                    //                 width: 2,
                    //               ),
                    //             ),
                    //             child: const Icon(
                    //               Icons.camera_alt,
                    //               color: Colors.white,
                    //               size: 20,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 30),

                    // Name
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama Anda',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan email Anda',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
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
                    const SizedBox(height: 20),

                    // Phone
                    const Text(
                      'Nomor Telepon',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nomor telepon Anda',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Alamat
                    const Text(
                      'Alamat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan alamat lengkap Anda',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Kecamatan Dropdown
                    const Text(
                      'Kecamatan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<KecamatanModel>(
                      initialValue: _selectedKecamatan,
                      decoration: InputDecoration(
                        hintText: 'Pilih Kecamatan',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                      items: _kecamatanList.map((kecamatan) {
                        return DropdownMenuItem<KecamatanModel>(
                          value: kecamatan,
                          child: Text(kecamatan.name),
                        );
                      }).toList(),
                      onChanged: (KecamatanModel? newValue) {
                        setState(() {
                          _selectedKecamatan = newValue;
                          _selectedKelurahan = null;
                          _kelurahanList = [];
                        });
                        if (newValue != null) {
                          _fetchKelurahan(newValue.id);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Kelurahan Dropdown
                    const Text(
                      'Kelurahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<KelurahanModel>(
                      initialValue: _selectedKelurahan,
                      decoration: InputDecoration(
                        hintText: 'Pilih Kelurahan',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                      ),
                      items: _kelurahanList.map((kelurahan) {
                        return DropdownMenuItem<KelurahanModel>(
                          value: kelurahan,
                          child: Text(kelurahan.name),
                        );
                      }).toList(),
                      onChanged: (KelurahanModel? newValue) {
                        setState(() {
                          _selectedKelurahan = newValue;
                        });
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
                                'Save',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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

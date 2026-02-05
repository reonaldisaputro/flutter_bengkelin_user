// lib/pages/home_page.dart

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter_bengkelin_user/config/app_color.dart';
import 'package:flutter_bengkelin_user/config/pref.dart';
import 'package:flutter_bengkelin_user/model/bengkel_model.dart';
import 'package:flutter_bengkelin_user/model/merk_mobil_model.dart';
import 'package:flutter_bengkelin_user/model/product_model.dart';
import 'package:flutter_bengkelin_user/model/specialist_model.dart';
import 'package:flutter_bengkelin_user/viewmodel/bengkel_viewmodel.dart';
import 'package:flutter_bengkelin_user/viewmodel/product_viewmodel.dart';
import 'package:flutter_bengkelin_user/viewmodel/specialist_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/bengkel_detail_page.dart';
import 'package:flutter_bengkelin_user/views/booking_form_page.dart';
import 'package:flutter_bengkelin_user/views/cart_page.dart';
import 'package:flutter_bengkelin_user/views/chat_assistant_page.dart';
import 'package:flutter_bengkelin_user/views/login_page.dart';
import 'package:flutter_bengkelin_user/views/product_detail_page.dart';
import 'package:flutter_bengkelin_user/views/profile_page.dart';
import 'package:flutter_bengkelin_user/widget/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/views/chat_page.dart';
import 'package:flutter_bengkelin_user/views/product_page.dart';
import 'package:flutter_bengkelin_user/views/service_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import '../model/product_list_response.dart';
import '../model/user_model.dart';
import '../viewmodel/profile_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  String _userName = 'Pengguna';
  String? _userPhotoUrl;

  List<Map<String, String>> filteredNearbyWorkshops = [];
  List<Map<String, String>> filteredRecommendedWorkshops = [];

  final TextEditingController _searchController = TextEditingController();

  bool _isNearbyLoading = true;
  List<BengkelModel> _bengkelNearby = [];
  String? _nearbyErrorMessage;

  // Radius filter for nearby bengkel
  final List<int> _radiusOptions = [5, 10, 20, 50];
  int _selectedRadius = 10;

  // Specialist filter
  List<SpecialistModel> _specialists = [];
  int? _selectedSpecialistId;
  String _searchKeyword = '';
  Timer? _debounce;
  bool _isBengkelLoading = true;

  // Merk Mobil filter
  List<MerkMobilModel> _merkMobils = [];
  int? _selectedMerkMobilId;

  @override
  void initState() {
    super.initState();
    getUserProfile();
    getProducts();
    getBengkelNearby();
    _getSpecialists();
    _getMerkMobils();
    getBengkel();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.length >= 3 || query.isEmpty) {
        setState(() {
          _searchKeyword = query.length >= 3 ? query : '';
        });
        getBengkel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePageContent(),
          // const ChatsPage(initialMessage: ''),
          ChatAssistantPage(),
          const ProductPage(),
          // const ServicePage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.build),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A6B6B),
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          // Tambahkan 'async' di sini
          if (index == 3) {
            // Index 3 adalah Profile
            String? userToken = await Session().getUserToken();
            if (userToken == null) {
              // Belum login, navigasi ke LoginPage
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
              return; // Penting: Jangan ubah _selectedIndex
            }
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHomePageContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                // String? userToken = await Session().getUserToken();
                // if (userToken == null){
                //   if (!mounted) return;
                //   Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                // } else {
                //   if (!mounted) return;
                //   Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(),),);
                // }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // CircleAvatar(
                    //   radius: 25,
                    //   backgroundColor: Colors.white,
                    //   backgroundImage:
                    //       _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                    //       ? NetworkImage(_userPhotoUrl!)
                    //       : null,
                    //   child: _userPhotoUrl == null || _userPhotoUrl!.isEmpty
                    //       ? Image.asset('assets/profile1.png')
                    //       : null,
                    // ),
                    // const SizedBox(width: 10),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     const Text(
                    //       'Selamat Datang',
                    //       style: TextStyle(fontSize: 14, color: Colors.grey),
                    //     ),
                    //     Text(
                    //       _users?.name ?? "",
                    //       style: const TextStyle(
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.bold,
                    //         color: Color(0xFF1A1A2E),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        String? userToken = await Session().getUserToken();
                        if (userToken == null) {
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        } else {
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartPage()),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari bengkel (min 3 karakter)',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'Bengkel Terdekat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Radius selector chips
            Container(
              height: 45,
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Radius:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _radiusOptions.length,
                      itemBuilder: (context, index) {
                        final radius = _radiusOptions[index];
                        final isSelected = _selectedRadius == radius;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text('$radius km'),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected && _selectedRadius != radius) {
                                setState(() {
                                  _selectedRadius = radius;
                                });
                                // Show a quick feedback toast
                                showToast(
                                  context: context,
                                  msg:
                                      'Mencari bengkel dalam radius $radius km...',
                                  duration: 2,
                                );
                                getBengkelNearby(); // Refresh data with new radius
                              }
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: const Color(
                              0xFF4A6B6B,
                            ).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF4A6B6B),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF4A6B6B)
                                  : Colors.grey[600],
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                            elevation: isSelected ? 2 : 0,
                            pressElevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF4A6B6B)
                                    : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 180, child: _buildNearbyContent()),
            const SizedBox(height: 25),
            // Padding(
            //   padding: const EdgeInsets.only(left: 16.0),
            //   child: Text(
            //     'Rekomendasi Product',
            //     style: TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.grey[800],
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 15),
            // SizedBox(
            //   height: 200,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //     itemCount: _products.length,
            //     itemBuilder: (context, index) {
            //       final product = _products[index];
            //       return GestureDetector(
            //         onTap: (){
            //           Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(productId: product.id, ),));
            //         },
            //         child: Container(
            //           width: 150,
            //           margin: const EdgeInsets.only(right: 15),
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             borderRadius: BorderRadius.circular(15),
            //             boxShadow: [
            //               BoxShadow(
            //                 color: Colors.black.withOpacity(0.05),
            //                 blurRadius: 10,
            //                 offset: const Offset(0, 5),
            //               ),
            //             ],
            //           ),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Stack(
            //                 children: [
            //                   ClipRRect(
            //                     borderRadius: const BorderRadius.vertical(
            //                       top: Radius.circular(15),
            //                     ),
            //                     child: Image.network(
            //                       '${dotenv.env["IMAGE_BASE_URL"]}/${product.image}', // placeholder image
            //                       height: 119,
            //                       width: double.infinity,
            //                       fit: BoxFit.cover,
            //                       errorBuilder: (context, error, stackTrace) {
            //                         return Container(
            //                           color: AppColor.colorGrey,
            //                           height: 119,
            //                           child: Center(
            //                             child: Text("Image not found", style: TextStyle(color: AppColor.white),),
            //                           ),
            //                         );
            //                       },
            //                     ),
            //                   ),
            //                   // Positioned(
            //                   //   top: 8,
            //                   //   right: 8,
            //                   //   child: Icon(
            //                   //     Icons.favorite_border,
            //                   //     color: Colors.grey[400],
            //                   //   ),
            //                   // ),
            //                 ],
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       product.name,
            //                       style: const TextStyle(
            //                         fontWeight: FontWeight.bold,
            //                         fontSize: 14,
            //                       ),
            //                       maxLines: 1,
            //                       overflow: TextOverflow.ellipsis,
            //                     ),
            //                     const SizedBox(height: 4),
            //                     Text(
            //                       product.bengkel.name,
            //                       style: TextStyle(
            //                         fontSize: 12,
            //                         color: Colors.grey[600],
            //                       ),
            //                       maxLines: 1,
            //                       overflow: TextOverflow.ellipsis,
            //                     ),
            //                     const SizedBox(height: 4),
            //                     Text(
            //                       'Rp ${product.price.toString()}',
            //                       style: const TextStyle(
            //                         fontWeight: FontWeight.bold,
            //                         fontSize: 14,
            //                         color: Color(0xFF4A6B6B),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'Rekomendasi Bengkel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Specialist Filter
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _specialists.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: const Text('Semua'),
                        selected: _selectedSpecialistId == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSpecialistId = null;
                            });
                            getBengkel();
                          }
                        },
                        selectedColor: const Color(0xFF4A6B6B),
                        labelStyle: TextStyle(
                          color: _selectedSpecialistId == null
                              ? Colors.white
                              : Colors.black,
                        ),
                        backgroundColor: Colors.white,
                      ),
                    );
                  }

                  final specialist = _specialists[index - 1];
                  final isSelected = _selectedSpecialistId == specialist.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(specialist.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSpecialistId = selected
                              ? specialist.id
                              : null;
                        });
                        getBengkel();
                      },
                      selectedColor: const Color(0xFF4A6B6B),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      backgroundColor: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Merk Mobil Filter (Dropdown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _selectedMerkMobilId,
                    hint: Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filter berdasarkan Merk Mobil',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.clear_all,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text('Semua Merk'),
                          ],
                        ),
                      ),
                      ..._merkMobils.map((merk) {
                        return DropdownMenuItem<int?>(
                          value: merk.id,
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                color: const Color(0xFF4A6B6B),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(merk.namaMerk),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMerkMobilId = value;
                      });
                      getBengkel();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _isBengkelLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _bengkel.length,
                    itemBuilder: (context, index) {
                      final bengkel = _bengkel[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  '${dotenv.env["IMAGE_BASE_URL"]}/${bengkel.image}',
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: AppColor.colorGrey,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bengkel.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            bengkel.kelurahan?.name ?? '-',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BengkelDetailPage(
                                        bengkelId: bengkel.id,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A6B6B),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Detail',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  List<ProductModel> _products = [];

  getProducts() async {
    await ProductViewmodel().products().then((value) {
      if (value.code == 200) {
        final responseData = value.data;
        final productList = ProductListResponse.fromJson(responseData);
        setState(() {
          _products = productList.products;
        });
      } else {
        if (!mounted) return;
        showToast(context: context, msg: value.message);
      }
    });
  }

  List<BengkelModel> _bengkel = [];

  Future<void> _getSpecialists() async {
    try {
      final value = await SpecialistViewmodel().getSpecialists();
      if (value.code == 200 || value.success == true) {
        final List<dynamic> data = value.data;
        setState(() {
          _specialists = data.map((e) => SpecialistModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading specialists: $e');
    }
  }

  Future<void> _getMerkMobils() async {
    try {
      final value = await BengkelViewmodel().getMerkMobil();
      if (value.success == true) {
        final List<dynamic> data = value.data;
        setState(() {
          _merkMobils = data.map((e) => MerkMobilModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading merk mobil: $e');
    }
  }

  getBengkel() async {
    setState(() {
      _isBengkelLoading = true;
    });

    await BengkelViewmodel()
        .listBengkel(
          keyword: _searchKeyword.isNotEmpty ? _searchKeyword : null,
          specialistId: _selectedSpecialistId,
          merkMobilId: _selectedMerkMobilId,
        )
        .then((value) {
          if (value.code == 200) {
            UnmodifiableListView listData = UnmodifiableListView(value.data);
            setState(() {
              _bengkel = listData.map((e) => BengkelModel.fromJson(e)).toList();
              _isBengkelLoading = false;
            });
          } else {
            setState(() {
              _isBengkelLoading = false;
            });
            if (!mounted) return;
            showToast(context: context, msg: value.message);
          }
        });
  }

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        showToast(context: context, msg: "Layanan lokasi dimatikan.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) showToast(context: context, msg: "Izin lokasi ditolak.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted)
        showToast(
          context: context,
          msg: "Izin lokasi ditolak permanen, mohon aktifkan di pengaturan.",
        );
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getBengkelNearby() async {
    setState(() {
      _isNearbyLoading = true;
      _nearbyErrorMessage = null;
    });

    try {
      final position = await _getCurrentPosition();

      if (position != null) {
        final value = await BengkelViewmodel().bengkelNearby(
          lat: position.latitude,
          long: position.longitude,
          radius: _selectedRadius,
        );

        if (value.code == 200) {
          // ==========================================================
          // ================== PERUBAHAN UTAMA DI SINI =================
          // ==========================================================

          // Langsung cast value.data sebagai List<dynamic>
          final List<dynamic> listData = value.data as List<dynamic>;

          // ==========================================================
          // ====================== AKHIR PERUBAHAN =====================
          // ==========================================================

          setState(() {
            _bengkelNearby = listData
                .map((e) => BengkelModel.fromJson(e))
                .toList();
            if (_bengkelNearby.isEmpty) {
              _nearbyErrorMessage = "Tidak ada bengkel terdekat ditemukan.";
            }
          });
        } else {
          setState(() {
            _nearbyErrorMessage = value.message;
          });
        }
      } else {
        setState(() {
          _nearbyErrorMessage = "Gagal mendapatkan lokasi Anda.";
        });
      }
    } catch (e) {
      setState(() {
        _nearbyErrorMessage = "Gagal memproses data bengkel.";
      });
      debugPrint("Error fetching nearby workshops: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isNearbyLoading = false;
        });
      }
    }
  }

  UserModel? _users;
  getUserProfile() async {
    setState(() {
      _users = null;
    });

    try {
      final respValue = await ProfileViewmodel().getUserProfile();

      if (!mounted) return;

      if (respValue.code == 200 && respValue.status == 'success') {
        if (respValue.data != null) {
          setState(() {
            _users = UserModel.fromJson(respValue.data);
          });
          debugPrint('User profile loaded successfully: ${_users?.name}');
        } else {
          setState(() {
            _users = null;
            debugPrint(
              'Failed to load user profile: Status 200/Success but data is null.',
            );
          });
        }
      } else {
        setState(() {
          _users = null;
          debugPrint(
            'Failed to load user profile: Code ${respValue.code}, Status: ${respValue.status}, Message: ${respValue.error ?? respValue.message}',
          );
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _users = null; // Tangani error jaringan atau lainnya
        debugPrint('Error loading user profile: $error');
      });
    }
  }

  Widget _buildNearbyContent() {
    // KASUS 1: SEDANG LOADING
    if (_isNearbyLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // KASUS 2: ADA ERROR ATAU DATA KOSONG
    if (_nearbyErrorMessage != null || _bengkelNearby.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _nearbyErrorMessage ?? "Tidak ada bengkel terdekat ditemukan.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    // KASUS 3: DATA BERHASIL DIDAPATKAN
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _bengkelNearby.length,
      itemBuilder: (context, index) {
        final bengkel = _bengkelNearby[index];
        // UI Card Anda sudah benar, tidak perlu diubah.
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BengkelDetailPage(bengkelId: bengkel.id),
              ),
            );
          },
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    '${dotenv.env["IMAGE_BASE_URL"]}/${bengkel.image}',
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        height: 100,
                        child: const Center(child: Icon(Icons.broken_image)),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bengkel.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bengkel.kelurahan?.name ?? 'Lokasi tidak tersedia',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

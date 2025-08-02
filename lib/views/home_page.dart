// lib/pages/home_page.dart

import 'dart:collection';

import 'package:flutter_bengkelin_user/config/app_color.dart';
import 'package:flutter_bengkelin_user/model/bengkel_model.dart';
import 'package:flutter_bengkelin_user/model/product_model.dart';
import 'package:flutter_bengkelin_user/viewmodel/bengkel_viewmodel.dart';
import 'package:flutter_bengkelin_user/viewmodel/product_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/bengkel_detail_page.dart';
import 'package:flutter_bengkelin_user/views/cart_page.dart';
import 'package:flutter_bengkelin_user/views/product_detail_page.dart';
import 'package:flutter_bengkelin_user/views/profile_page.dart';
import 'package:flutter_bengkelin_user/widget/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/views/chat_page.dart';
import 'package:flutter_bengkelin_user/views/product_page.dart';
import 'package:flutter_bengkelin_user/views/service_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  final List<String> _locationOptions = [
    'Sumatra selatan',
    'Sumatra utara',
    'Sumatra barat',
    'Jakarta',
    'Bandung',
    'Surabaya',
  ];

  String _currentSelectedLocation = 'Sumatra selatan';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserProfile();
    getProducts();
    getBengkel();
    getUserProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePageContent(),
          const ChatsPage(initialMessage: ''),
          const ProductPage(),
          const ServicePage(),
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
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Service',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A6B6B),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
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
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(),),);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                          ? NetworkImage(_userPhotoUrl!)
                          : null,
                      child: _userPhotoUrl == null || _userPhotoUrl!.isEmpty
                          ? Image.asset('assets/profile1.png')
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          _users?.name ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(),));
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currentSelectedLocation,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _currentSelectedLocation,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF4A6B6B),
                    ),
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      setState(() {});
                    },
                    items: _locationOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Color(0xFF4A6B6B)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by service name or product',
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
            const SizedBox(height: 15),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _bengkel.length,
                itemBuilder: (context, index) {
                  final bengkel = _bengkel[index];
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BengkelDetailPage(bengkelId: bengkel.id),));
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
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
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'Rekomendasi Product',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: product, ),));
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
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.network(
                                  '${dotenv.env["IMAGE_BASE_URL"]}/${product.image}', // placeholder image
                                  height: 119,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColor.colorGrey,
                                      height: 119,
                                      child: Center(
                                        child: Text("Image not found", style: TextStyle(color: AppColor.white),),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.favorite_border,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.bengkel.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${product.price.toString()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF4A6B6B),
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
            ),
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
            const SizedBox(height: 15),
            ListView.builder(
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
                                child: Icon(Icons.image_not_supported, color: Colors.white),
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
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      bengkel.kelurahan?.name ?? '-',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                            // Aksi booking
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6B6B),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'BOOK',
                            style: TextStyle(color: Colors.white, fontSize: 14),
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
  getBengkel() async {
    await BengkelViewmodel().listBengkel().then((value) {
      if (value.code == 200) {
        UnmodifiableListView listData = UnmodifiableListView(value.data);
        setState(() {
          _bengkel = listData.map((e) => BengkelModel.fromJson(e)).toList();
        });
      } else {
        if (!mounted) return;
        showToast(context: context, msg: value.message);
      }
    });
  }

  UserModel? _users;
  getUserProfile() async {
    setState(() {
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
            );
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


}

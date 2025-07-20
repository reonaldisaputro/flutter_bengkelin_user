import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/views/chat_page.dart';
import 'package:flutter_bengkelin_user/views/service_category_page.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  // Data dummy untuk kategori layanan
  final List<Map<String, dynamic>> serviceCategories = [
    {
      'name': 'General Repair',
      'icon': Icons.build,
      'services': [
        {
          'name': 'Car Inspection',
          'price': 'Rp 250.000',
          'image': 'assets/inpeksi_mobil.jpg',
          'description': 'Pengecekan menyeluruh kondisi mobil.',
        },
        {
          'name': 'Oli Change',
          'price': 'Rp 150.000',
          'image': 'assets/ganti_oli.jpg',
          'description': 'Penggantian oli mesin.',
        },
        {
          'name': 'Tire Change',
          'price': 'Rp 426.000',
          'image': 'assets/ganti_ban.jpg',
          'description': 'Penggantian ban mobil.',
        },
        {
          'name': 'Engine Repair',
          'price': 'Rp 550.000',
          'image': 'assets/perbaikan_mesin.jpg',
          'description': 'Perbaikan mesin mobil.',
        },
      ],
    },
    {
      'name': 'Machine',
      'icon': Icons.precision_manufacturing,
      'services': [
        {
          'name': 'Tune Up Mesin',
          'price': 'Rp 400.000',
          'image': 'assets/tune_up.jpg',
          'description': 'Penyetelan ulang performa mesin.',
        },
      ],
    },
    {
      'name': 'Body',
      'icon': Icons.car_repair,
      'services': [
        {
          'name': 'Body Repair',
          'price': 'Rp 700.000',
          'image': 'assets/cat_mobil.jpg',
          'description': 'Perbaikan bodi mobil yang penyok.',
        },
      ],
    },
  ];

  // Data dummy untuk pilihan bengkel
  final List<Map<String, dynamic>> availableWorkshops = [
    {
      'name': 'Bengkel Pak Jamil',
      'location': 'Jakarta',
      'image': 'assets/bengkel1.jpg',
    },
    {
      'name': 'Bengkel Sumber Jaya',
      'location': 'Surabaya',
      'image': 'assets/bengkel2.jpg',
    },
    {
      'name': 'Bengkel Maju Bersama',
      'location': 'Bandung',
      'image': 'assets/bengkel3.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (Colors.grey[300]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),
            // Search Bar dengan Box Shadow
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Carilah yang anda inginkan',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: serviceCategories.map((category) {
                return _buildCategoryCard(context, category);
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Chat Bot dengan Box Shadow
            GestureDetector(
              onTap: () {
                // Navigasi ke ChatsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatsPage(initialMessage: ''),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/chatbot.jpg',
                      width: 40,
                      height: 40,
                    ), // Pastikan gambar ini ada
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chat Bot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tanya bot jika anda ingin mendapat saran',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bengkel Terdekat',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableWorkshops.length,
                itemBuilder: (context, index) {
                  final workshop = availableWorkshops[index];
                  return _buildWorkshopCard(workshop);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildCategoryCard
  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceCategoryPage(
              categoryName: category['name']!,
              categoryServices: category['services']!,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              category['icon'] as IconData,
              size: 40,
              color: const Color(0xFF4F625D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category['name']!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk kartu bengkel
  Widget _buildWorkshopCard(Map<String, dynamic> workshop) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                workshop['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workshop['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  workshop['location']!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
